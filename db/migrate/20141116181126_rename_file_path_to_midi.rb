class RenameFilePathToMidi < ActiveRecord::Migration
  def change
    rename_column :sequences, :file_path, :midi
  end
end
