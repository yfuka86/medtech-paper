class CreatePaperPaperLists < ActiveRecord::Migration
  def change
    create_table :paper_paper_lists do |t|
      t.integer :paper_id
      t.integer :paper_list_id

      t.timestamps null: false
    end
  end
end
