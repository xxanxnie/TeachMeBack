class Match < ApplicationRecord
  belongs_to :user1, class_name: "User"
  belongs_to :user2, class_name: "User"

  validates :status, presence: true
  validates :user1_id, uniqueness: { scope: :user2_id }

  validate :different_users
  validate :user1_id_less_than_user2_id

  def other_user(user)
    user.id == user1_id ? user2 : user1
  end

  def includes_user?(user)
    user1_id == user.id || user2_id == user.id
  end

  private

  def different_users
    if user1_id == user2_id
      errors.add(:user2, "must be different from user1")
    end
  end

  def user1_id_less_than_user2_id
    if user1_id.present? && user2_id.present? && user1_id >= user2_id
      errors.add(:user1_id, "must be less than user2_id")
    end
  end
end

