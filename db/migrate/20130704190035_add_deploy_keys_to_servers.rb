class AddDeployKeysToServers < ActiveRecord::Migration
  def change
    add_column :servers, :ssh_deploy_keys, :text
  end
end
