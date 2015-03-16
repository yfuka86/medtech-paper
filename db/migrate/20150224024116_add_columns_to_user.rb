class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string, limit: 20
    add_column :users, :department, :integer
    add_column :users, :hospital_name, :string, limit: 50

    add_index :users, :username
  end
end
