class AddRailsEnvironmentToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :rails_environment, :string, default: 'production'
  end
end
