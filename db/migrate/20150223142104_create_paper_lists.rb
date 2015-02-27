class CreatePaperLists < ActiveRecord::Migration
  def change
    create_table :paper_lists do |t|
      t.integer :user_id
      t.string :title
      t.integer :category, default: 0
      t.boolean :is_public, default: false

      t.timestamps null: false
    end
  end
end
