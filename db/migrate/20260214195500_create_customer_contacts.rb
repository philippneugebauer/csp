class CreateCustomerContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_contacts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false

      t.timestamps
    end

    add_index :customer_contacts, [ :customer_id, :email ]
  end
end
