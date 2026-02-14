class DashboardController < ApplicationController
  def index
    @customers_count = Customer.count
    @high_risk_count = Customer.high.count
    @renewal_count = Customer.renewal.count

    @customers_by_stage = Customer.group(:stage).count
    @customers_by_risk = Customer.group(:churn_risk).count

    @at_risk_customers = Customer
      .includes(:customer_success_manager, :customer_contacts)
      .high
      .order(updated_at: :desc)
      .limit(8)

    @recent_notes = NoteActivity
      .includes(:customer, :customer_success_manager)
      .order(occurred_at: :desc)
      .limit(8)
  end
end
