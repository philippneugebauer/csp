class CustomerSuccessManager < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :customer_notes, dependent: :destroy
  has_many :customer_email_messages, dependent: :destroy

  has_secure_password

  scope :active, -> { where(deleted_at: nil) }

  before_validation :normalize_email

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  def full_name
    [ first_name, last_name ].compact.join(" ")
  end

  private
    def normalize_email
      self.email = email.to_s.downcase.strip
    end
end
