require "test_helper"

class CustomerTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @manager = customer_success_managers(:one)
    sign_in_as(@manager)
  end

  test "creates task activity" do
    assert_difference("TaskActivity.count", 1) do
      post customer_customer_tasks_url(@customer), params: {
        customer_task: {
          body: "Prepare QBR agenda"
        }
      }
    end

    task = TaskActivity.order(:id).last
    assert_redirected_to customer_url(@customer)
    assert_equal "Prepare QBR agenda", task.body
    assert_equal @manager, task.customer_success_manager
  end

  test "rejects blank task" do
    assert_no_difference("TaskActivity.count") do
      post customer_customer_tasks_url(@customer), params: {
        customer_task: {
          body: ""
        }
      }
    end

    assert_redirected_to customer_url(@customer)
  end

  test "completes task activity" do
    task = TaskActivity.create!(
      customer: @customer,
      customer_success_manager: @manager,
      body: "Follow up with legal",
      occurred_at: Time.current
    )

    patch complete_customer_customer_task_url(@customer, task)

    assert_redirected_to customer_url(@customer)
    assert task.reload.completed_at.present?
  end
end
