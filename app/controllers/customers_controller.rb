class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy sync_emails history gmv_trend ]

  # GET /customers or /customers.json
  def index
    @customer_success_managers = CustomerSuccessManager.active.order(:first_name, :last_name)

    @name_query = params[:name].to_s.strip
    @customer_success_manager_id = params[:customer_success_manager_id].to_s
    @stage_filter = params[:stage].to_s
    @churn_risk_filter = params[:churn_risk].to_s

    @customers = Customer.includes(:customer_success_manager).order(:name)

    if @name_query.present?
      escaped_name = ActiveRecord::Base.sanitize_sql_like(@name_query)
      @customers = @customers.where("customers.name LIKE ?", "%#{escaped_name}%")
    end

    if @customer_success_manager_id.present?
      @customers = @customers.where(customer_success_manager_id: @customer_success_manager_id)
    end

    if Customer.stages.key?(@stage_filter)
      @customers = @customers.where(stage: Customer.stages[@stage_filter])
    end

    if Customer.churn_risks.key?(@churn_risk_filter)
      @customers = @customers.where(churn_risk: Customer.churn_risks[@churn_risk_filter])
    end
  end

  # GET /customers/1 or /customers/1.json
  def show
    @activity_type = params[:activity_type].presence_in(%w[all notes documents emails gmv]) || "all"
    @email_direction = params[:email_direction].presence_in(%w[all inbound outbound]) || "all"
    @show_completed_tasks = ActiveModel::Type::Boolean.new.cast(params[:show_completed_tasks])

    @customer_note = NoteActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      occurred_at: Time.current
    )
    @task_activities = @customer.task_activities.includes(:customer_success_manager).recent_first
    @task_activities = @task_activities.incomplete unless @show_completed_tasks
    @task_activities = @task_activities.limit(10)

    @activities = @customer.activities
      .where.not(type: "TaskActivity")
      .includes(:customer_success_manager, documents_attachments: :blob)
      .recent_first

    if @activity_type == "notes"
      @activities = @activities.where(type: "NoteActivity").where.missing(:documents_attachments)
    elsif @activity_type == "documents"
      @activities = @activities.where(type: "NoteActivity").where.associated(:documents_attachments).distinct
    elsif @activity_type == "gmv"
      @activities = @activities.where(type: "GmvActivity")
    end

    if @activity_type == "emails"
      @activities = @activities.where(type: "EmailActivity")
      @activities = @activities.public_send(@email_direction) if @email_direction != "all"
    end
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, notice: "Customer was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /customers/1/sync_emails
  def sync_emails
    SyncCustomerEmailsJob.perform_later(@customer.id)
    redirect_to @customer, notice: "Gmail sync has been queued."
  end

  # GET /customers/1/history
  def history
    versions_asc = @customer.versions.order(:created_at, :id).to_a
    @versions = versions_asc.reverse
    @version_actors = CustomerSuccessManager
      .where(id: versions_asc.map(&:whodunnit).compact)
      .index_by { |csm| csm.id.to_s }
      .transform_values(&:full_name)
    @version_changes = versions_asc.each_with_object({}) do |version, hash|
      changes = deserialize_object_changes(version.object_changes).except("created_at", "updated_at")
      hash[version.id] = sanitize_changes(changes)
    end
  end

  # GET /customers/1/gmv_trend
  def gmv_trend
    @gmv_series = @customer.gmv_activities
      .where.not(gmv_on: nil)
      .group(:gmv_on)
      .sum(:gmv_revenue)
      .sort
      .to_h
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      permitted = params.require(:customer).permit(
        :name,
        :organization_id,
        :stage,
        :churn_risk,
        :contract_start_date,
        :contract_termination_date,
        :travel_budget,
        :customer_success_manager_id,
        customer_contacts_attributes: {}
      )

      raw_contacts = permitted.delete(:customer_contacts_attributes) || {}
      sanitized_contacts = raw_contacts.to_h.transform_values do |attrs|
        attrs.to_h.slice("id", "name", "email", "_destroy")
      end

      permitted[:customer_contacts_attributes] = sanitized_contacts
      permitted
    end

    def sanitize_changes(changes)
      changes.each_with_object({}) do |(attribute, values), sanitized|
        from, to = Array(values)
        normalized_from = normalize_attribute_value(attribute, from)
        normalized_to = normalize_attribute_value(attribute, to)
        next if normalized_from == normalized_to

        sanitized[attribute] = [ normalized_from, normalized_to ]
      end
    end

    def normalize_attribute_value(attribute, value)
      return nil if value.nil?

      enum_mapping = @customer.class.defined_enums[attribute.to_s]
      if enum_mapping.present?
        return value if enum_mapping.key?(value.to_s)

        integer_value = Integer(value, exception: false)
        return enum_mapping.key(integer_value) if integer_value
      end

      type = @customer.class.type_for_attribute(attribute.to_s)
      if type.is_a?(ActiveRecord::Type::Json) && value.is_a?(String)
        begin
          return JSON.parse(value)
        rescue JSON::ParserError
          return value
        end
      end

      value
    end

    def deserialize_object_changes(raw_object_changes)
      return {} if raw_object_changes.blank?

      deserialized = JSON.parse(raw_object_changes)
      return deserialized.to_h if deserialized.respond_to?(:to_h)

      {}
    rescue StandardError
      {}
    end
end
