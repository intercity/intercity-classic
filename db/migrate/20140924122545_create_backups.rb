class CreateBackups < ActiveRecord::Migration
  def change
    create_table :backups do |t|
      t.boolean :enabled, default: false
      t.references :application, index: true
      t.integer :storage_type, default: 0
      t.string :dropbox_api_key
      t.string :dropbox_api_secret

      t.timestamps
    end
  end
end
