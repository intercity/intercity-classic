class AddS3DataToBackup < ActiveRecord::Migration
  def change
    add_column :backups, :s3_access_key, :string
    add_column :backups, :s3_secret_access_key, :string
    add_column :backups, :s3_bucket, :string
    add_column :backups, :s3_region, :string, default: "eu-west-1"
  end
end
