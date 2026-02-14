class AddAuthToCustomerSuccessManagers < ActiveRecord::Migration[8.1]
  def change
    add_column :customer_success_managers, :password_digest, :string
    add_index :customer_success_managers, :email
  end
end
