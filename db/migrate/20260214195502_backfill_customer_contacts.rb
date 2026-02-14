class BackfillCustomerContacts < ActiveRecord::Migration[8.1]
  class MigrationCustomer < ApplicationRecord
    self.table_name = "customers"
  end

  class MigrationCustomerContact < ApplicationRecord
    self.table_name = "customer_contacts"
  end

  def up
    MigrationCustomer.find_each do |customer|
      next if MigrationCustomerContact.exists?(customer_id: customer.id)

      contacts = Array(customer.contact_persons).select { |entry| entry.is_a?(Hash) }

      if contacts.any?
        contacts.each do |contact|
          name = contact["name"].to_s.strip
          email = contact["email"].to_s.strip.downcase
          next if name.blank? || email.blank?

          MigrationCustomerContact.create!(customer_id: customer.id, name: name, email: email)
        end
      elsif customer.primary_contact_email.present?
        MigrationCustomerContact.create!(
          customer_id: customer.id,
          name: "Primary Contact",
          email: customer.primary_contact_email.downcase
        )
      end
    end
  end

  def down
    # no-op
  end
end
