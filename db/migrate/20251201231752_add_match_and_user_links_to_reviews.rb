class AddMatchAndUserLinksToReviews < ActiveRecord::Migration[7.0]
  def change
    # Add match_id column (nullable for existing rows)
    add_column :reviews, :match_id, :integer

    # Add indexes for performance
    add_index :reviews, :match_id
    add_index :reviews, :reviewer_id
    add_index :reviews, :reviewee_id

    # Add foreign keys for integrity
    add_foreign_key :reviews, :matches, column: :match_id
    add_foreign_key :reviews, :users, column: :reviewer_id
    add_foreign_key :reviews, :users, column: :reviewee_id

    # Strengthen constraints on existing columns
    change_column_null :reviews, :rating, false
    change_column_null :reviews, :reviewer_id, false
    change_column_null :reviews, :reviewee_id, false

    # Optional: prevent duplicate reviews per match per reviewer
    add_index :reviews, [:match_id, :reviewer_id], unique: true
  end
end
