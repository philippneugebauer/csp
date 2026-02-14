class AddCompletedAtToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :completed_at, :datetime
    add_index :activities, :completed_at
  end
end
