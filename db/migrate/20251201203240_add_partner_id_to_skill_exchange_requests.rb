class AddPartnerIdToSkillExchangeRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :skill_exchange_requests, :partner_id, :integer
    add_foreign_key :skill_exchange_requests, :users, column: :partner_id
  end
end
