class AddEduVerifiedToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :edu_verified, :boolean
  end
end
