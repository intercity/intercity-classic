class AddDigitalOceanTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :digitalocean_access_token, :string
  end
end
