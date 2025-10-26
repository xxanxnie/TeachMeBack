class User < ApplicationRecord
  validates :name,  presence: true
  validates :email, presence: true
  validate  :edu_email_only

  before_validation :set_edu_verified

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
  
