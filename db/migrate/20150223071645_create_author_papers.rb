class CreateAuthorPapers < ActiveRecord::Migration
  def change
    create_table :author_papers do |t|
      t.integer :author_id
      t.integer :paper_id

      t.timestamps null: false
    end
  end
end
