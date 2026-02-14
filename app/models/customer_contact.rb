class CustomerContact < ApplicationRecord
  belongs_to :customer

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  private
    def normalize_email
      self.email = email.to_s.downcase.strip
    end
end
