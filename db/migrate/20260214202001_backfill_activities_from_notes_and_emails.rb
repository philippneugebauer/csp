class BackfillActivitiesFromNotesAndEmails < ActiveRecord::Migration[8.1]
  class MigrationCustomerNote < ApplicationRecord
    self.table_name = "customer_notes"
  end

  class MigrationCustomerEmailMessage < ApplicationRecord
    self.table_name = "customer_email_messages"
  end

  class MigrationActivity < ApplicationRecord
    self.table_name = "activities"
    self.inheritance_column = :_type_disabled
  end

  def up
    MigrationCustomerNote.find_each do |note|
      MigrationActivity.create!(
        type: "NoteActivity",
        customer_id: note.customer_id,
        customer_success_manager_id: note.customer_success_manager_id,
        body: note.body,
        occurred_at: note.noted_at || note.created_at,
        created_at: note.created_at,
        updated_at: note.updated_at
      )
    end

    MigrationCustomerEmailMessage.find_each do |email|
      MigrationActivity.create!(
        type: "EmailActivity",
        customer_id: email.customer_id,
        customer_success_manager_id: email.customer_success_manager_id,
        occurred_at: email.sent_at || email.created_at,
        gmail_message_id: email.gmail_message_id,
        gmail_thread_id: email.gmail_thread_id,
        direction: email.direction,
        subject: email.subject,
        from_email: email.from_email,
        to_email: email.to_email,
        snippet: email.snippet,
        body_text: email.body_text,
        metadata: email.metadata || {},
        created_at: email.created_at,
        updated_at: email.updated_at
      )
    end
  end

  def down
    MigrationActivity.where(type: %w[NoteActivity EmailActivity]).delete_all
  end
end
