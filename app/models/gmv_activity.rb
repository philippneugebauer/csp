class GmvActivity < Activity
  validates :gmv_on, presence: true
  validates :gmv_revenue, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_occurred_at, on: :create

  private
    def set_occurred_at
      return if occurred_at.present? || gmv_on.blank?

      self.occurred_at = gmv_on.in_time_zone.end_of_day
    end
end
