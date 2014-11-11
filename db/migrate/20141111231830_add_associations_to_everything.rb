class AddAssociationsToEverything < ActiveRecord::Migration
  def change
    add_column :notes, :sequence_id, :integer
    add_column :sessions, :sequence_id, :integer
    add_column :sessions, :user_id, :integer
  end
end
