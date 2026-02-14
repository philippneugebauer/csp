class EmailActivity < Activity
  enum :direction, {
    inbound: 0,
    outbound: 1
  }, default: :inbound

  validates :gmail_message_id, presence: true, uniqueness: true

  before_validation :set_occurred_at, on: :create

  private
    def set_occurred_at
      self.occurred_at ||= Time.current
    end
end
