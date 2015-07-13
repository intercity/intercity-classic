class AddStaffToUser < ActiveRecord::Migration
  def change
    add_column :users, :staff, :boolean, default: false
  end
end
