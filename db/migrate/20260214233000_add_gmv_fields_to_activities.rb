class AddGmvFieldsToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :gmv_on, :date
    add_column :activities, :gmv_revenue, :decimal, precision: 12, scale: 2
    add_index :activities, :gmv_on
  end
end
