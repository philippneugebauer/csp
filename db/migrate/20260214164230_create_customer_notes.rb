class CreateCustomerNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_notes do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :customer_success_manager, null: false, foreign_key: true
      t.text :body, null: false
      t.datetime :noted_at, null: false

      t.timestamps
    end

    add_index :customer_notes, :noted_at
  end
end
