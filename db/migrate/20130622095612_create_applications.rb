class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :name
      t.string :domain_names

      t.string :database_password
      t.string :database_user

      t.belongs_to :server

      t.timestamps
    end
  end
end
