class TaskActivity < Activity
  validates :body, presence: true

  scope :incomplete, -> { where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }

  before_validation :set_occurred_at, on: :create

  def completed?
    completed_at.present?
  end

  def complete!
    update!(completed_at: Time.current) unless completed?
  end

  private
    def set_occurred_at
      self.occurred_at ||= Time.current
    end
end
