class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.integer :pubmed_id
      t.datetime :received_date
      t.datetime :accepted_date
      t.datetime :published_date
      t.string :title
      t.integer :volume
      t.integer :issue
      t.string :pages
      t.integer :journal_id
      t.text :abstract
      t.text :rawdata

      t.timestamps null: false
    end
  end
end
