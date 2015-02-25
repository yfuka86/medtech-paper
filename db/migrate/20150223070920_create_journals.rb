class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.string :iso_jta
      t.string :ml_jta
      t.string :name
      t.string :issn

      t.timestamps null: false
    end
  end
end
