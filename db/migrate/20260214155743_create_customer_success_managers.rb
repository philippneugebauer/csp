class CreateCustomerSuccessManagers < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_success_managers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email

      t.timestamps
    end
  end
end
