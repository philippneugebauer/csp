class CustomerGmvActivitiesController < ApplicationController
  before_action :set_customer

  # POST /customers/:customer_id/customer_gmv_activities
  def create
    activity = GmvActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      gmv_on: customer_gmv_activity_params[:gmv_on],
      gmv_revenue: customer_gmv_activity_params[:gmv_revenue]
    )

    if activity.save
      redirect_to @customer, notice: "GMV activity was successfully added."
    else
      redirect_to @customer, alert: activity.errors.full_messages.to_sentence
    end
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:customer_id))
    end

    def customer_gmv_activity_params
      params.expect(customer_gmv_activity: [ :gmv_on, :gmv_revenue ])
    end
end
