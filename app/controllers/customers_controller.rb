class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy sync_emails ]

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
    @activity_type = params[:activity_type].presence_in(%w[all notes documents emails]) || "all"
    @email_direction = params[:email_direction].presence_in(%w[all inbound outbound]) || "all"

    @customer_note = NoteActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      occurred_at: Time.current
    )
    @customer_task = TaskActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      occurred_at: Time.current
    )
    @task_activities = @customer.activities.where(type: "TaskActivity").includes(:customer_success_manager).recent_first.limit(10)

    @activities = @customer.activities
      .where.not(type: "TaskActivity")
      .includes(:customer_success_manager, documents_attachments: :blob)
      .recent_first

    if @activity_type == "notes"
      @activities = @activities.where(type: "NoteActivity").where.missing(:documents_attachments)
    elsif @activity_type == "documents"
      @activities = @activities.where(type: "NoteActivity").where.associated(:documents_attachments).distinct
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
end
