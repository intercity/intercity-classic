class AddClientMaxBodySizeToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :client_max_body_size, :integer, default: 20
  end
end
