class RemoveDateStartedFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :date_started, :datetime
  end
end
