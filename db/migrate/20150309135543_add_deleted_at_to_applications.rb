class AddDeletedAtToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :deleted_at, :datetime
    add_index :applications, :deleted_at
  end
end
