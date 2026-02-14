class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy sync_emails ]

  # GET /customers or /customers.json
  def index
    @customers = Customer.includes(:customer_success_manager).order(:name)
  end

  # GET /customers/1 or /customers/1.json
  def show
    @customer_note = @customer.customer_notes.new(
      customer_success_manager: @customer.customer_success_manager,
      noted_at: Time.current
    )
    @customer_notes = @customer.customer_notes.includes(:customer_success_manager).order(noted_at: :desc)
    @customer_email_messages = @customer.customer_email_messages.order(sent_at: :desc, created_at: :desc)
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
      params.expect(customer: [ :name, :primary_contact_email, :stage, :churn_risk, :customer_success_manager_id ])
    end
end
