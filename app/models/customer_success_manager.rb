class CustomerSuccessManager < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :note_activities, -> { where(type: "NoteActivity") }, class_name: "Activity", dependent: :destroy
  has_many :email_activities, -> { where(type: "EmailActivity") }, class_name: "Activity", dependent: :destroy

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
