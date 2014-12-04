class SetDefaultBpmTo120 < ActiveRecord::Migration
  def change
    change_column :sequences, :bpm, :integer, :default => 120
  end
end
