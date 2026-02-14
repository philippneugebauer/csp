class Customer < ApplicationRecord
  belongs_to :customer_success_manager
  has_many :customer_notes, dependent: :destroy
  has_many :customer_email_messages, dependent: :destroy

  enum :stage, {
    onboarding: 0,
    adoption: 1,
    value_realization: 2,
    renewal: 3
  }, default: :onboarding

  enum :churn_risk, {
    low: 0,
    medium: 1,
    high: 2
  }, default: :low

  validates :name, presence: true
  validates :primary_contact_email, presence: true
end
