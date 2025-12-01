class Review < ApplicationRecord
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewee, class_name: "User"
  belongs_to :skill_exchange_request

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true
end
