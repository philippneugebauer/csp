class CustomerSuccessManager < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :customer_notes, dependent: :destroy
  has_many :customer_email_messages, dependent: :destroy

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end
end
