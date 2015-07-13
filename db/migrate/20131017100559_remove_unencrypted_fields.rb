class RemoveUnencryptedFields < ActiveRecord::Migration
  def change
    remove_column :applications, :database_user
    remove_column :applications, :database_password

    remove_column :servers, :rsa_key
    remove_column :servers, :mysql_passwords
  end
end
