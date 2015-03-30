class CreatePaperPaperLists < ActiveRecord::Migration
  def change
    create_table :paper_paper_lists do |t|
      t.integer :paper_id
      t.integer :paper_list_id
      t.date :read_date

      t.timestamps null: false
    end

    add_index :paper_paper_lists, [:paper_id, :paper_list_id], unique: true
  end
end
