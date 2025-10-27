class User < ApplicationRecord
  has_many :skill_exchange_requests, dependent: :destroy
  has_secure_password
end 
