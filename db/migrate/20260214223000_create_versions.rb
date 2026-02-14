class CreateVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :versions do |t|
      t.string :whodunnit
      t.datetime :created_at
      t.bigint :item_id, null: false
      t.string :item_type
      t.string :event, null: false
      t.text :object, limit: 1.gigabyte - 1
      t.text :object_changes, limit: 1.gigabyte - 1
    end

    add_index :versions, %i[item_type item_id]
    add_index :versions, :created_at
    add_index :versions, :whodunnit
  end
end
