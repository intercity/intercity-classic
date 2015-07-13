class AddPostgresPasswordsEcryptedToServer < ActiveRecord::Migration
  def change
    add_column :servers, :postgres_passwords_encrypted, :binary
  end
end
