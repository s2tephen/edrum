class RenameTimeToBars < ActiveRecord::Migration
  def change
    rename_column :sequences, :time, :bars
  end
end
