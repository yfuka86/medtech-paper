class CreatePaperListUsers < ActiveRecord::Migration
  def change
    create_table :paper_list_users do |t|
      t.integer :paper_list_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
