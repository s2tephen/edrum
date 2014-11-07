class RemoveFieldsFromSequences < ActiveRecord::Migration
  def change
    remove_column :sequences, :top_score, :integer
    remove_column :sequences, :last_played, :datetime
    remove_column :sequences, :times_practiced, :integer
  end
end
