class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.string :symbol
      t.string :full_name

      t.timestamps null: false
    end
  end
end
