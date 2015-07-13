class CopyUnencryptedFieldsIntoEncryptedFields < ActiveRecord::Migration
  def change
    change_table :servers do |t|
      t.binary :rsa_key_encrypted
      t.binary :mysql_passwords_encrypted
    end

    change_table :applications do |t|
      t.binary :database_user_encrypted
      t.binary :database_password_encrypted
    end

    Server.where(address: '').destroy_all

    Server.all.each do |server|
      server.rsa_key_encrypted = server.rsa_key
      server.mysql_passwords_encrypted = server.mysql_passwords
      server.save!
    end

    Application.all.each do |application|
      application.database_user_encrypted = application.database_user
      application.database_password_encrypted = application.database_password
      application.save!
    end
  end
end
