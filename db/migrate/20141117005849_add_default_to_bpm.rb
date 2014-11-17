class AddDefaultToBpm < ActiveRecord::Migration
  def change
    rename_column :sequences, :default_bpm, :bpm
    change_column :sequences, :bpm, :integer, :default => 100
  end
end
