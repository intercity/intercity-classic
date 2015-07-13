class AddEnableSslToApplications < ActiveRecord::Migration
  def change
    add_column :applications, :enable_ssl, :boolean, default: false
  end
end
