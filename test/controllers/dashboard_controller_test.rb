require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to login when signed out" do
    get root_url
    assert_redirected_to login_url
  end

  test "should get index when signed in" do
    sign_in_as(customer_success_managers(:one))

    get root_url
    assert_response :success
    assert_includes response.body, "/customers?churn_risk=high"
  end
end
