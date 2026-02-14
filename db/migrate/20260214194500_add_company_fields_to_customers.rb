class AddCompanyFieldsToCustomers < ActiveRecord::Migration[8.1]
  def change
    add_column :customers, :organization_id, :string
    add_column :customers, :customer_segment, :integer, null: false, default: 3
    add_column :customers, :contact_persons, :json, null: false, default: []
    add_column :customers, :contract_start_date, :date
    add_column :customers, :contract_termination_date, :date
    add_column :customers, :travel_budget, :decimal, precision: 12, scale: 2

    add_index :customers, :organization_id
    add_index :customers, :customer_segment
  end
end
