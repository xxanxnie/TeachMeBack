class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bio, :text unless column_exists?(:users, :bio)
    add_column :users, :location, :string unless column_exists?(:users, :location)
    add_column :users, :university, :string unless column_exists?(:users, :university)
  end
end


