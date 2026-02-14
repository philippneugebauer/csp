class CustomerNote < ApplicationRecord
  belongs_to :customer
  belongs_to :customer_success_manager

  validates :body, presence: true
  validates :noted_at, presence: true

  before_validation :set_noted_at, on: :create

  private
    def set_noted_at
      self.noted_at ||= Time.current
    end
end
