class AddDeletingToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :deleting, :boolean, default: false, nil: false
  end
end
