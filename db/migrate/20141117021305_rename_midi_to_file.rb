class RenameMidiToFile < ActiveRecord::Migration
  def change
    rename_column :sequences, :midi, :file
  end
end
