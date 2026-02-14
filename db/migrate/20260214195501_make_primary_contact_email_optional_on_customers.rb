class MakePrimaryContactEmailOptionalOnCustomers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :customers, :primary_contact_email, true
  end
end
