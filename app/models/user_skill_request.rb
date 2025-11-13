class UserSkillRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"

  validates :skill, presence: true
  validate :cannot_request_self

  after_create :check_for_reciprocal_match

  private

  def cannot_request_self
    if requester_id == receiver_id
      errors.add(:receiver, "cannot be yourself")
    end
  end

  def check_for_reciprocal_match
    reverse_request = UserSkillRequest.exists?(
      requester_id: receiver_id,
      receiver_id: requester_id
    )

    if reverse_request
      # Create a match if one doesn't already exist
      user_ids = [requester_id, receiver_id].sort
      unless Match.exists?(user1_id: user_ids[0], user2_id: user_ids[1])
        match = Match.create!(
          user1_id: user_ids[0],
          user2_id: user_ids[1],
          status: "mutual"
        )
      end
    end
  end
end

