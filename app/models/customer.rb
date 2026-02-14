class Customer < ApplicationRecord
  if defined?(::PaperTrail::Model)
    include ::PaperTrail::Model unless respond_to?(:has_paper_trail)
    has_paper_trail
  end

  belongs_to :customer_success_manager
  has_many :activities, dependent: :destroy
  has_many :note_activities, -> { where(type: "NoteActivity") }, class_name: "Activity", dependent: :destroy
  has_many :email_activities, -> { where(type: "EmailActivity") }, class_name: "Activity", dependent: :destroy
  has_many :gmv_activities, -> { where(type: "GmvActivity") }, class_name: "GmvActivity", dependent: :destroy
  has_many :task_activities, -> { where(type: "TaskActivity") }, class_name: "TaskActivity", dependent: :destroy
  has_many :customer_contacts, dependent: :destroy

  accepts_nested_attributes_for :customer_contacts, allow_destroy: true, reject_if: :all_blank

  enum :stage, {
    onboarding: 0,
    adoption: 1,
    value_realization: 2,
    renewal: 3
  }, default: :onboarding

  enum :churn_risk, {
    low: 0,
    medium: 1,
    high: 2
  }, default: :low

  enum :customer_segment, {
    a_plus: 0,
    a: 1,
    b: 2,
    c: 3,
    d: 4
  }, default: :c

  before_validation :compute_customer_segment

  validates :name, presence: true
  validates :travel_budget, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_contract_dates
  validate :must_have_at_least_one_contact_person

  def customer_segment_label
    customer_segment == "a_plus" ? "A+" : customer_segment.to_s.upcase
  end

  def sync_contact_email
    customer_contacts.reject(&:marked_for_destruction?).first&.email || primary_contact_email
  end

  def monthly_gmv_total(reference_date = Date.current)
    gmv_total_for(reference_date.beginning_of_month..reference_date.end_of_month)
  end

  def quarterly_gmv_total(reference_date = Date.current)
    gmv_total_for(reference_date.beginning_of_quarter..reference_date.end_of_quarter)
  end

  def monthly_engagement_percentage(reference_date = Date.current)
    percentage_of_target(monthly_gmv_total(reference_date), monthly_travel_budget_target)
  end

  def quarterly_engagement_percentage(reference_date = Date.current)
    percentage_of_target(quarterly_gmv_total(reference_date), quarterly_travel_budget_target)
  end

  private
    def gmv_total_for(range)
      gmv_activities.where(gmv_on: range).sum(:gmv_revenue).to_d
    end

    def monthly_travel_budget_target
      return if travel_budget.blank?

      travel_budget.to_d / 12
    end

    def quarterly_travel_budget_target
      return if travel_budget.blank?

      travel_budget.to_d / 4
    end

    def percentage_of_target(actual, target)
      return if target.blank? || target.zero?

      ((actual.to_d / target.to_d) * 100).round(1)
    end

    def compute_customer_segment
      self.customer_segment = if high?
        :d
      elsif medium?
        (renewal? || value_realization?) ? :b : :c
      elsif renewal?
        :a_plus
      elsif value_realization?
        :a
      elsif adoption?
        :b
      else
        :c
      end
    end

    def must_have_at_least_one_contact_person
      kept_contacts = customer_contacts.reject(&:marked_for_destruction?)
      return if kept_contacts.any?

      errors.add(:customer_contacts, "must include at least one contact person")
    end

    def validate_contract_dates
      return if contract_start_date.blank? || contract_termination_date.blank?
      return if contract_termination_date >= contract_start_date

      errors.add(:contract_termination_date, "must be on or after contract start date")
    end
end
