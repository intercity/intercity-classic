class AddRsaKeyEncryptedToOnboarding < ActiveRecord::Migration
  def change
    add_column :onboardings, :rsa_key_encrypted, :binary
  end
end
