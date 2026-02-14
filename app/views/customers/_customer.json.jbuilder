json.extract! customer, :id, :name, :organization_id, :stage, :customer_segment, :churn_risk, :contract_start_date, :contract_termination_date, :travel_budget, :customer_success_manager_id, :created_at, :updated_at
json.contact_persons customer.customer_contacts.map { |contact| { name: contact.name, email: contact.email } }
json.url customer_url(customer, format: :json)
