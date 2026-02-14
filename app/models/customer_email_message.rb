class CustomerEmailMessage < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_success_manager

  enum :direction, {
    inbound: 0,
    outbound: 1
  }, default: :inbound

  validates :gmail_message_id, presence: true, uniqueness: true
end
