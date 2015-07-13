class AddDeployUserToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :deploy_user, :string, default: 'deploy'
  end
end
