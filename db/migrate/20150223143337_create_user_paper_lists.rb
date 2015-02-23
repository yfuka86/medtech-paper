class CreateUserPaperLists < ActiveRecord::Migration
  def change
    create_table :user_paper_lists do |t|
      t.integer :paper_list_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
