require "test_helper"

class CustomerSuccessManagersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer_success_manager = customer_success_managers(:one)
    sign_in_as(@customer_success_manager)
  end

  test "should get index" do
    get customer_success_managers_url
    assert_response :success
  end

  test "should get new" do
    get new_customer_success_manager_url
    assert_response :success
  end

  test "should create customer_success_manager" do
    assert_difference("CustomerSuccessManager.count") do
      post customer_success_managers_url, params: {
        customer_success_manager: {
          email: "new_manager@example.com",
          first_name: "New",
          last_name: "Manager",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to customer_success_manager_url(CustomerSuccessManager.last)
  end

  test "should show customer_success_manager" do
    get customer_success_manager_url(@customer_success_manager)
    assert_response :success
  end

  test "should get edit" do
    get edit_customer_success_manager_url(@customer_success_manager)
    assert_response :success
  end

  test "should update customer_success_manager" do
    patch customer_success_manager_url(@customer_success_manager), params: {
      customer_success_manager: {
        email: @customer_success_manager.email,
        first_name: @customer_success_manager.first_name,
        last_name: @customer_success_manager.last_name
      }
    }
    assert_redirected_to customer_success_manager_url(@customer_success_manager)
  end

  test "should destroy customer_success_manager" do
    manager = customer_success_managers(:two)

    assert_difference("CustomerSuccessManager.count", -1) do
      delete customer_success_manager_url(manager)
    end

    assert_redirected_to customer_success_managers_url
  end

  test "should not destroy current customer_success_manager" do
    assert_no_difference("CustomerSuccessManager.count") do
      delete customer_success_manager_url(@customer_success_manager)
    end

    assert_redirected_to customer_success_managers_url
  end
end
