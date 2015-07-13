class AddDigitaloceanRegionToServer < ActiveRecord::Migration
  def change
    add_column :servers, :digitalocean_region, :integer, default: 0
  end
end
