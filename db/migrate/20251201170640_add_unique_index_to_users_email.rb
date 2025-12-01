class AddUniqueIndexToUsersEmail < ActiveRecord::Migration[7.0]  # match your version
  def change
    add_index :users, :email, unique: true
  end
end

