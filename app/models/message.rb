class Message < ApplicationRecord
  belongs_to :sender,    class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true, length: { maximum: 2000 }
  validate :sender_and_recipient_different

  scope :between, ->(a_id, b_id) {
    where(sender_id: a_id, recipient_id: b_id)
      .or(where(sender_id: b_id, recipient_id: a_id))
      .order(:created_at)
  }

  private

  def sender_and_recipient_different
    errors.add(:recipient_id, "must be a different user") if sender_id == recipient_id
  end
end

