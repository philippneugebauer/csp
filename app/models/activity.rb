class Activity < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_success_manager
  has_many_attached :documents

  validates :occurred_at, presence: true

  scope :recent_first, -> { order(occurred_at: :desc, created_at: :desc) }
end
