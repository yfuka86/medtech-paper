class CreatePaperLists < ActiveRecord::Migration
  def change
    create_table :paper_lists do |t|
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
