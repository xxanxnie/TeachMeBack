class User < ApplicationRecord
    has_many :skill_exchange_requests, dependent: :destroy
  end
  