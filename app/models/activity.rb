class Activity < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_success_manager

  validates :occurred_at, presence: true

  scope :recent_first, -> { order(occurred_at: :desc, created_at: :desc) }
end
