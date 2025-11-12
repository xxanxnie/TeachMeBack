class CreateMatches < ActiveRecord::Migration[7.1]
  def change
    create_table :matches do |t|
      t.references :user1, null: false, foreign_key: { to_table: :users }
      t.references :user2, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "mutual"

      t.timestamps
    end

    add_index :matches, [:user1_id, :user2_id], unique: true
    add_index :matches, [:user2_id, :user1_id]
  end
end

