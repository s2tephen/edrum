class CreateSequences < ActiveRecord::Migration
  def change
    create_table :sequences do |t|
      t.string :title
      t.string :artist
      t.integer :default_bpm
      t.integer :meter_top
      t.integer :meter_bottom
      t.integer :time

      t.timestamps
    end
  end
end
