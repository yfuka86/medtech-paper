class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :department, :integer
    add_column :users, :hospital_name, :string

    add_index :users, :username
  end
end
