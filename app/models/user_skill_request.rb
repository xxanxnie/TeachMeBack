class UserSkillRequest < ApplicationRecord
  belongs_to :requester, class_name: "User"
  belongs_to :receiver, class_name: "User"
  belongs_to :skill_exchange_request, optional: true

  validates :skill, presence: true
  validates :skill_exchange_request_id, uniqueness: { scope: [:requester_id, :receiver_id], allow_nil: true }
  validate :cannot_request_self

  after_create :check_for_reciprocal_match

  private

  def cannot_request_self
    if requester_id == receiver_id
      errors.add(:receiver, "cannot be yourself")
    end
  end

  def check_for_reciprocal_match
    reverse_request = UserSkillRequest.find_by(
      requester_id: receiver_id,
      receiver_id: requester_id
    )

    return unless reverse_request

    # Check if there's a reciprocal skill exchange possible:
    # - User1 wants to learn skill_A from User2
    # - User2 wants to learn skill_B from User1
    # - User1 must be able to teach skill_B (has a SkillExchangeRequest teaching skill_B)
    # - User2 must be able to teach skill_A (has a SkillExchangeRequest teaching skill_A)
    
    skill_user1_wants_to_learn = skill # what requester wants to learn from receiver
    skill_user2_wants_to_learn = reverse_request.skill # what receiver wants to learn from requester
    
    # Check if requester can teach what receiver wants to learn
    # Only check open requests (matched ones are already taken)
    # Use case-insensitive comparison for skill names
    requester_can_teach = SkillExchangeRequest.where(
      user_id: requester_id,
      status: :open
    ).where("LOWER(teach_skill) = ?", skill_user2_wants_to_learn.to_s.downcase.strip).exists?
    
    # Check if receiver can teach what requester wants to learn
    # Only check open requests (matched ones are already taken)
    # Use case-insensitive comparison for skill names
    receiver_can_teach = SkillExchangeRequest.where(
      user_id: receiver_id,
      status: :open
    ).where("LOWER(teach_skill) = ?", skill_user1_wants_to_learn.to_s.downcase.strip).exists?

    # Only create match if both can teach what the other wants to learn
    if requester_can_teach && receiver_can_teach
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
