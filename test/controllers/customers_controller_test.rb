require "test_helper"

class CustomersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    sign_in_as(customer_success_managers(:one))
  end

  test "should get index" do
    get customers_url
    assert_response :success
  end

  test "should filter index by name csm stage and churn risk" do
    manager = customer_success_managers(:two)

    get customers_url, params: {
      name: "Glob",
      customer_success_manager_id: manager.id,
      stage: "renewal",
      churn_risk: "high"
    }

    assert_response :success
    assert_includes response.body, "Globex"
    assert_not_includes response.body, "Acme Inc"
  end

  test "should get new" do
    get new_customer_url
    assert_response :success
  end

  test "should create customer" do
    assert_difference([ "Customer.count", "CustomerContact.count" ], 1) do
      post customers_url, params: {
        customer: {
          churn_risk: @customer.churn_risk,
          customer_success_manager_id: @customer.customer_success_manager_id,
          name: "NewCo",
          stage: @customer.stage,
          customer_contacts_attributes: {
            "0" => { name: "Main Contact", email: "contact@newco.example" }
          }
        }
      }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should create customer with dynamically keyed contact attributes" do
    dynamic_key = "1700000000_1234"

    assert_difference([ "Customer.count", "CustomerContact.count" ], 1) do
      post customers_url, params: {
        customer: {
          name: "DynamicCo",
          stage: @customer.stage,
          churn_risk: @customer.churn_risk,
          customer_success_manager_id: @customer.customer_success_manager_id,
          customer_contacts_attributes: {
            dynamic_key => { name: "Dynamic Contact", email: "dynamic@example.com" }
          }
        }
      }
    end

    assert_redirected_to customer_url(Customer.last)
  end

  test "should show customer" do
    get customer_url(@customer)
    assert_response :success
  end

  test "should get customer history" do
    patch customer_url(@customer), params: {
      customer: {
        name: "Acme Updated",
        stage: @customer.stage,
        churn_risk: @customer.churn_risk,
        customer_success_manager_id: @customer.customer_success_manager_id,
        customer_contacts_attributes: {
          "0" => {
            id: @customer.customer_contacts.first.id,
            name: @customer.customer_contacts.first.name,
            email: @customer.customer_contacts.first.email
          }
        }
      }
    }

    get history_customer_url(@customer)
    assert_response :success
    assert_includes response.body, "Customer History"
    assert_includes response.body, "Update"
    assert_includes response.body, "Name"
    assert_includes response.body, "Acme Updated"
  end

  test "should hide completed tasks by default and show when requested" do
    manager = customer_success_managers(:one)
    TaskActivity.create!(
      customer: @customer,
      customer_success_manager: manager,
      body: "Open task visible",
      occurred_at: Time.current
    )
    TaskActivity.create!(
      customer: @customer,
      customer_success_manager: manager,
      body: "Completed task hidden",
      occurred_at: Time.current,
      completed_at: Time.current
    )

    get customer_url(@customer)
    assert_response :success
    assert_includes response.body, "Open task visible"
    assert_not_includes response.body, "Completed task hidden"

    get customer_url(@customer), params: { show_completed_tasks: "1" }
    assert_response :success
    assert_includes response.body, "Completed task hidden"
  end

  test "should get edit" do
    get edit_customer_url(@customer)
    assert_response :success
  end

  test "should update customer" do
    contact = @customer.customer_contacts.first

    patch customer_url(@customer), params: {
      customer: {
        churn_risk: @customer.churn_risk,
        customer_success_manager_id: @customer.customer_success_manager_id,
        name: @customer.name,
        stage: @customer.stage,
        customer_contacts_attributes: {
          "0" => { id: contact.id, name: contact.name, email: contact.email }
        }
      }
    }
    assert_redirected_to customer_url(@customer)
  end

  test "should destroy customer" do
    assert_difference("Customer.count", -1) do
      delete customer_url(@customer)
    end

    assert_redirected_to customers_url
  end
end
