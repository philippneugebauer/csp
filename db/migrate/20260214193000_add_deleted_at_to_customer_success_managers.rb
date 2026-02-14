class AddDeletedAtToCustomerSuccessManagers < ActiveRecord::Migration[8.1]
  def change
    add_column :customer_success_managers, :deleted_at, :datetime
    add_index :customer_success_managers, :deleted_at
  end
end
