class User < ApplicationRecord
  has_many :skill_exchange_requests, dependent: :destroy
  has_many :sent_skill_requests, class_name: "UserSkillRequest", foreign_key: "requester_id", dependent: :destroy
  has_many :received_skill_requests, class_name: "UserSkillRequest", foreign_key: "receiver_id", dependent: :destroy
  has_many :matches_as_user1, class_name: "Match", foreign_key: "user1_id", dependent: :destroy
  has_many :matches_as_user2, class_name: "Match", foreign_key: "user2_id", dependent: :destroy

  has_many :sent_messages,
           class_name: "Message",
           foreign_key: :sender_id,
           dependent: :destroy

  has_many :received_messages,
           class_name: "Message",
           foreign_key: :recipient_id,
           dependent: :destroy
-
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true
  validate  :edu_email_only

  before_validation :set_edu_verified
  before_validation :set_display_name

  def full_name
    fn = [first_name.to_s.strip, last_name.to_s.strip].reject(&:blank?).join(" ")
    fn.presence || name.to_s
  end

  def matches
    Match.where("user1_id = ? OR user2_id = ?", id, id)
  end

  def matched_with?(other_user)
    user_ids = [id, other_user.id].sort
    Match.exists?(user1_id: user_ids[0], user2_id: user_ids[1])
  end

  def has_sent_request_to?(other_user)
    sent_skill_requests.exists?(receiver_id: other_user.id)
  end

  def has_received_request_from?(other_user)
    received_skill_requests.exists?(requester_id: other_user.id)
  def message_label
    full_name.presence || email.to_s
  end

  def thread_partners
    sent_ids     = Message.where(sender_id: id).pluck(:recipient_id)
    received_ids = Message.where(recipient_id: id).pluck(:sender_id)
    partner_ids  = (sent_ids + received_ids).uniq - [id]
    User.where(id: partner_ids)
  end

  def unread_messages_count
    Message.where(recipient_id: id, read_at: nil).count
  end

  private

  def set_display_name
    if name.to_s.strip.blank?
      composed = [first_name.to_s.strip, last_name.to_s.strip].reject(&:blank?).join(" ")
      self.name = composed if composed.present?
    end
  end

  def edu_email_only
    unless email&.end_with?(".edu")
      errors.add(:email, ".edu email required")
    end
  end

  def set_edu_verified
    self.edu_verified = email&.end_with?(".edu")
  end
end

