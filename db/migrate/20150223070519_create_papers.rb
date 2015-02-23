class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.integer :pubmed_id
      t.date :received_date
      t.date :accepted_date
      t.date :published_date
      t.string :title
      t.integer :volume
      t.integer :issue
      t.string :pages
      t.text :abstract
      t.text :rawdata

      t.timestamps null: false
    end
  end
end
