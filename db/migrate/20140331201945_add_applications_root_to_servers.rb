class AddApplicationsRootToServers < ActiveRecord::Migration
  def change
    add_column :servers, :applications_root, :string, default: '/u/apps'
  end
end
