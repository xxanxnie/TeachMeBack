class CreateUserSkillRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :user_skill_requests do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.string :skill, null: false

      t.timestamps
    end

    add_index :user_skill_requests, [:requester_id, :receiver_id]
    add_index :user_skill_requests, [:receiver_id, :requester_id]
  end
end

