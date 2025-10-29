class User < ApplicationRecord
  has_many :skill_exchange_requests, dependent: :destroy
  has_secure_password
  validates :name,  presence: true
  validates :email, presence: true
  validate  :edu_email_only

  before_validation :set_edu_verified
  before_validation :set_display_name

  def full_name
    fn = [first_name.to_s.strip, last_name.to_s.strip].reject(&:blank?).join(" ")
    fn.presence || name.to_s
  end

  private

  def set_display_name
    if name.to_s.strip.blank?
      composed = [first_name.to_s.strip, last_name.to_s.strip].reject(&:blank?).join(" ")
      self.name = composed if composed.present?
    end
  end

  private

  def edu_email_only
    unless email&.end_with?(".edu")
      errors.add(:email, ".edu email required")
    end
  end

  def set_edu_verified
    self.edu_verified = email&.end_with?(".edu")
  end
end
