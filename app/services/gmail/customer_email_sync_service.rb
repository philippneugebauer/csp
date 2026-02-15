require "base64"
require "json"
require "net/http"
require "uri"

module Gmail
  class CustomerEmailSyncService
    GMAIL_API_BASE_URL = "https://gmail.googleapis.com/gmail/v1/users/me".freeze

    def initialize(customer, access_token: ENV["GMAIL_ACCESS_TOKEN"])
      @customer = customer
      @access_token = access_token
    end

    def sync!
      raise "GMAIL_ACCESS_TOKEN is missing" if @access_token.blank?
      raise "Customer contact email is missing" if @customer.sync_contact_email.blank?

      list = gmail_get("/messages", q: search_query, maxResults: 25)
      message_refs = list.fetch("messages", [])

      message_refs.sum do |message_ref|
        upsert_message!(message_ref.fetch("id")) ? 1 : 0
      end
    end

    private
      def upsert_message!(gmail_message_id)
        payload = gmail_get("/messages/#{gmail_message_id}", format: "full")
        headers = headers_hash(payload)

        record = EmailActivity.find_or_initialize_by(
          customer_id: @customer.id,
          gmail_message_id: gmail_message_id
        )

        record.customer = @customer
        record.customer_success_manager = @customer.customer_success_manager
        record.occurred_at = parse_datetime(headers["date"])
        record.gmail_thread_id = payload["threadId"]
        record.direction = message_direction(headers["from"])
        record.subject = headers["subject"]
        record.from_email = headers["from"]
        record.to_email = headers["to"]
        record.snippet = payload["snippet"]
        record.body_text = body_text(payload["payload"])
        record.metadata = {
          label_ids: payload["labelIds"],
          history_id: payload["historyId"],
          internal_date: payload["internalDate"]
        }

        record.save!
      end

      def message_direction(from_header)
        csm_email = @customer.customer_success_manager&.email.to_s.downcase
        return :inbound if csm_email.blank?

        from_header.to_s.downcase.include?(csm_email) ? :outbound : :inbound
      end

      def parse_datetime(date_header)
        Time.zone.parse(date_header)
      rescue StandardError
        Time.zone.now
      end

      def search_query
        customer_email = @customer.sync_contact_email
        "(from:#{customer_email} OR to:#{customer_email}) newer_than:365d"
      end

      def headers_hash(payload)
        payload
          .dig("payload", "headers")
          .to_a
          .each_with_object({}) { |h, hash| hash[h["name"].to_s.downcase] = h["value"] }
      end

      def body_text(payload)
        return if payload.blank?

        part = find_text_part(payload)
        data = part&.dig("body", "data")
        return if data.blank?

        Base64.urlsafe_decode64(data)
      rescue StandardError
        nil
      end

      def find_text_part(part)
        return part if part["mimeType"] == "text/plain"

        Array(part["parts"]).each do |nested_part|
          found = find_text_part(nested_part)
          return found if found
        end

        nil
      end

      def gmail_get(path, params = {})
        uri = URI("#{GMAIL_API_BASE_URL}#{path}")
        if params.any?
          uri.query = URI.encode_www_form(params)
        end

        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{@access_token}"
        request["Accept"] = "application/json"

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        unless response.is_a?(Net::HTTPSuccess)
          raise "Gmail API error (#{response.code}): #{response.body}"
        end

        JSON.parse(response.body)
      end
  end
end
