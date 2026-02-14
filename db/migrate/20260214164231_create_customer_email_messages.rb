class CreateCustomerEmailMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_email_messages do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :customer_success_manager, null: false, foreign_key: true
      t.string :gmail_message_id, null: false
      t.string :gmail_thread_id
      t.integer :direction, null: false, default: 0
      t.string :subject
      t.string :from_email
      t.string :to_email
      t.text :snippet
      t.text :body_text
      t.datetime :sent_at
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :customer_email_messages, :gmail_message_id, unique: true
    add_index :customer_email_messages, :gmail_thread_id
    add_index :customer_email_messages, :sent_at
  end
end
