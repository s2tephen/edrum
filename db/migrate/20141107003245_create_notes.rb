class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.integer :bar
      t.integer :beat
      t.integer :duration
      t.integer :drum

      t.timestamps
    end
  end
end
