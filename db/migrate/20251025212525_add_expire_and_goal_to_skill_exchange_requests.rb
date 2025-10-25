class AddExpireAndGoalToSkillExchangeRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :skill_exchange_requests, :expires_after_days, :integer
    add_column :skill_exchange_requests, :learning_goal, :text
  end
end
