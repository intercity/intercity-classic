class AddUnattendedUpgradesToServers < ActiveRecord::Migration
  def change
    add_column :servers, :unattended_upgrades, :boolean, default: false
  end
end
