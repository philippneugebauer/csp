class CustomerTasksController < ApplicationController
  before_action :set_customer
  before_action :set_task, only: :complete

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

  # PATCH /customers/:customer_id/customer_tasks/:id/complete
  def complete
    @task.complete!
    redirect_to customer_path(@customer, preserved_query_params), notice: "Task marked as completed."
  end

  private
    def set_customer
      @customer = Customer.find(params.expect(:customer_id))
    end

    def set_task
      @task = @customer.activities.find_by!(id: params.expect(:id), type: "TaskActivity")
    end

    def customer_task_params
      params.expect(customer_task: [ :body ])
    end

    def preserved_query_params
      params.permit(:activity_type, :email_direction, :show_completed_tasks).to_h.compact_blank
    end
end
