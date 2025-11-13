class AddCategoriesToSkillExchangeRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :skill_exchange_requests, :teach_category, :string
    add_column :skill_exchange_requests, :learn_category, :string
  end
end
