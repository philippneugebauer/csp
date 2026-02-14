class CustomerSuccessManagersController < ApplicationController
  before_action :set_customer_success_manager, only: %i[ show edit update destroy ]

  # GET /customer_success_managers or /customer_success_managers.json
  def index
    @customer_success_managers = CustomerSuccessManager.all
  end

  # GET /customer_success_managers/1 or /customer_success_managers/1.json
  def show
  end

  # GET /customer_success_managers/new
  def new
    @customer_success_manager = CustomerSuccessManager.new
  end

  # GET /customer_success_managers/1/edit
  def edit
  end

  # POST /customer_success_managers or /customer_success_managers.json
  def create
    @customer_success_manager = CustomerSuccessManager.new(customer_success_manager_params)

    respond_to do |format|
      if @customer_success_manager.save
        format.html { redirect_to @customer_success_manager, notice: "Customer success manager was successfully created." }
        format.json { render :show, status: :created, location: @customer_success_manager }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer_success_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customer_success_managers/1 or /customer_success_managers/1.json
  def update
    respond_to do |format|
      if @customer_success_manager.update(customer_success_manager_params)
        format.html { redirect_to @customer_success_manager, notice: "Customer success manager was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @customer_success_manager }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer_success_manager.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_success_managers/1 or /customer_success_managers/1.json
  def destroy
    @customer_success_manager.destroy!

    respond_to do |format|
      format.html { redirect_to customer_success_managers_path, notice: "Customer success manager was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer_success_manager
      @customer_success_manager = CustomerSuccessManager.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_success_manager_params
      params.expect(customer_success_manager: [ :first_name, :last_name, :email ])
    end
end
