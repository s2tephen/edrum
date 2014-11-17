class AddHandToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :hand, :string
  end
end
