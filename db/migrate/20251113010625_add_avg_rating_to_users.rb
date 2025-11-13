class AddAvgRatingToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :avg_rating, :float
  end
end
