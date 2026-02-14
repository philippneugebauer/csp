json.extract! customer, :id, :name, :primary_contact_email, :stage, :churn_risk, :customer_success_manager_id, :created_at, :updated_at
json.url customer_url(customer, format: :json)
