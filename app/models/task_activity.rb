class TaskActivity < Activity
  validates :body, presence: true

  before_validation :set_occurred_at, on: :create

  private
    def set_occurred_at
      self.occurred_at ||= Time.current
    end
end
