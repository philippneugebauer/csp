class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.string :type, null: false
      t.references :customer, null: false, foreign_key: true
      t.references :customer_success_manager, null: false, foreign_key: true

      t.text :body
      t.datetime :occurred_at, null: false

      t.string :gmail_message_id
      t.string :gmail_thread_id
      t.integer :direction
      t.string :subject
      t.string :from_email
      t.string :to_email
      t.text :snippet
      t.text :body_text
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :activities, :type
    add_index :activities, :occurred_at
    add_index :activities, :gmail_thread_id
    add_index :activities, :gmail_message_id, unique: true
  end
end
