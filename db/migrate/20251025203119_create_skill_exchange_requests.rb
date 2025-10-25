class CreateSkillExchangeRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :skill_exchange_requests do |t|
      t.references :user, null: false, foreign_key: true

      t.string  :teach_skill, null: false
      t.string  :learn_skill, null: false
      t.integer :offer_hours, null: false, default: 1
      t.integer :availability_mask, null: false, default: 0

      t.integer :teach_level, null: false, default: 2
      t.integer :learn_level, null: false, default: 1
      t.string  :modality, null: false, default: "in_person"
      t.text    :notes

      t.integer :status, null: false, default: 0
      t.integer :visibility, null: false, default: 0

      t.timestamps
    end

    add_index :skill_exchange_requests, [:status, :visibility]
  end
end
