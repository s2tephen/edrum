class AddFieldsToSequences < ActiveRecord::Migration
  def change
    add_column :sequences, :file_path, :string
    add_column :sequences, :top_score, :integer
    add_column :sequences, :last_played, :datetime
    add_column :sequences, :date_added, :datetime
    add_column :sequences, :times_practiced, :integer
  end
end
