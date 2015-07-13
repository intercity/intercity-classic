class AddDigitaloceanIdToServer < ActiveRecord::Migration
  def change
    add_column :servers, :digitalocean_id, :integer
  end
end
