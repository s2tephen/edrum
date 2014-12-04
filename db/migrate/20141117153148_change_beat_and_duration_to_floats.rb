class ChangeBeatAndDurationToFloats < ActiveRecord::Migration
  def change
    change_column :notes, :beat, :float
    change_column :notes, :duration, :float
  end
end
