class AddSkillExchangeRequestToUserSkillRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_skill_requests, :skill_exchange_request, foreign_key: true
    add_index :user_skill_requests,
              [:requester_id, :receiver_id, :skill_exchange_request_id],
              unique: true,
              name: "idx_usr_requests_on_requester_receiver_ser"
  end
end
