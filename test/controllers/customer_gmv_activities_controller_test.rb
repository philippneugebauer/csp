require "test_helper"

class CustomerGmvActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = customers(:one)
    @manager = customer_success_managers(:one)
    sign_in_as(@manager)
  end

  test "creates gmv activity" do
    assert_difference("GmvActivity.count", 1) do
      post customer_customer_gmv_activities_url(@customer), params: {
        customer_gmv_activity: {
          gmv_on: "2026-02-14",
          gmv_revenue: "1234.56"
        }
      }
    end

    activity = GmvActivity.order(:id).last
    assert_redirected_to customer_url(@customer)
    assert_equal Date.new(2026, 2, 14), activity.gmv_on
    assert_equal BigDecimal("1234.56"), activity.gmv_revenue
  end
end
