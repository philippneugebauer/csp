class CustomerTasksController < ApplicationController
  before_action :set_customer

  # POST /customers/:customer_id/customer_tasks
  def create
    task = TaskActivity.new(
      customer: @customer,
      customer_success_manager: current_customer_success_manager,
      body: customer_task_params[:body],
      occurred_at: Time.current
    )

    if task.save
      redirect_to @customer, notice: "Task was successfully added."
    else
      redirect_to @customer, alert: task.errors.full_messages.to_sentence
    end
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:customer_id))
    end

    def customer_task_params
      params.expect(customer_task: [ :body ])
    end
end
