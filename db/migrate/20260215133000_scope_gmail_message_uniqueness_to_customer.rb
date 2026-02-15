class ScopeGmailMessageUniquenessToCustomer < ActiveRecord::Migration[8.1]
  def change
    remove_index :activities, name: "index_activities_on_gmail_message_id"
    add_index :activities, [ :customer_id, :gmail_message_id ],
      unique: true,
      name: "index_activities_on_customer_id_and_gmail_message_id"
  end
end
