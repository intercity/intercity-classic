class AddDatabaseFromOtherApplicationToApplications < ActiveRecord::Migration
  def change
    change_table :applications do |t|
      t.belongs_to :connect_to_database_from_application
      t.boolean :use_database_from_other_application
    end
  end
end
