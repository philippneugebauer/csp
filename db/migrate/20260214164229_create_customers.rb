class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :name, null: false
      t.string :primary_contact_email, null: false
      t.integer :stage, null: false, default: 0
      t.integer :churn_risk, null: false, default: 0
      t.references :customer_success_manager, null: false, foreign_key: true

      t.timestamps
    end

    add_index :customers, :primary_contact_email
  end
end
