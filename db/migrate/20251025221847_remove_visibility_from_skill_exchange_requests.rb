class RemoveVisibilityFromSkillExchangeRequests < ActiveRecord::Migration[8.1]
  def change
    remove_column :skill_exchange_requests, :visibility, :integer
  end
end
