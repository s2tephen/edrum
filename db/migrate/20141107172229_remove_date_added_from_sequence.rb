class RemoveDateAddedFromSequence < ActiveRecord::Migration
  def change
    remove_column :sequences, :date_added, :datetime
  end
end
