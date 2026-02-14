require "test_helper"

class CustomerTest < ActiveSupport::TestCase
  test "computes monthly and quarterly engagement from gmv and travel budget" do
    customer = customers(:one)
    customer.update!(travel_budget: 1200)

    reference_date = Date.new(2026, 2, 14)

    GmvActivity.create!(
      customer: customer,
      customer_success_manager: customer.customer_success_manager,
      gmv_on: Date.new(2026, 2, 5),
      gmv_revenue: 50
    )
    GmvActivity.create!(
      customer: customer,
      customer_success_manager: customer.customer_success_manager,
      gmv_on: Date.new(2026, 2, 10),
      gmv_revenue: 100
    )
    GmvActivity.create!(
      customer: customer,
      customer_success_manager: customer.customer_success_manager,
      gmv_on: Date.new(2026, 1, 20),
      gmv_revenue: 150
    )

    # Q1 total = 300, monthly target = 100, quarterly target = 300
    assert_equal BigDecimal("150.0"), customer.monthly_gmv_total(reference_date)
    assert_equal BigDecimal("300.0"), customer.quarterly_gmv_total(reference_date)
    assert_equal BigDecimal("150.0"), customer.monthly_engagement_percentage(reference_date)
    assert_equal BigDecimal("100.0"), customer.quarterly_engagement_percentage(reference_date)
  end

  test "returns nil engagement without travel budget" do
    customer = customers(:one)
    customer.update!(travel_budget: nil)

    assert_nil customer.monthly_engagement_percentage
    assert_nil customer.quarterly_engagement_percentage
  end
end
