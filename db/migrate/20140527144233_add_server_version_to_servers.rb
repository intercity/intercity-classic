class AddServerVersionToServers < ActiveRecord::Migration
  def change
    add_column :servers, :server_version, :string
  end
end
