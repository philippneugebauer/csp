class ConvertPaperTrailPayloadsToJson < ActiveRecord::Migration[8.1]
  class Version < ActiveRecord::Base
    self.table_name = "versions"
  end

  def up
    say_with_time "Converting PaperTrail payloads from YAML to JSON" do
      Version.find_each do |version|
        updates = {}

        %w[object object_changes].each do |column|
          raw = version.public_send(column)
          next if raw.blank?

          serialized = serialize_as_json(raw)
          updates[column] = serialized if serialized != raw
        end

        version.update_columns(updates) if updates.any?
      end
    end
  end

  def down
    # no-op: conversion is one-way
  end

  private
    def serialize_as_json(raw)
      return raw if json_payload?(raw)

      payload = YAML.safe_load(
        raw,
        permitted_classes: [ Date, Time, Symbol, BigDecimal, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone ],
        aliases: true
      )

      JSON.generate(normalize(payload))
    rescue StandardError
      raw
    end

    def json_payload?(raw)
      JSON.parse(raw)
      true
    rescue JSON::ParserError
      false
    end

    def normalize(value)
      case value
      when Hash
        value.to_h.transform_keys(&:to_s).transform_values { |entry| normalize(entry) }
      when Array
        value.map { |entry| normalize(entry) }
      when ActiveSupport::TimeWithZone, Time, Date
        value.iso8601
      when BigDecimal
        value.to_s("F")
      when Symbol
        value.to_s
      else
        value
      end
    end
end
