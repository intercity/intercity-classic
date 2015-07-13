class AddSslInfoToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :ssl_key, :text
    add_column :applications, :ssl_cert, :text
  end
end
