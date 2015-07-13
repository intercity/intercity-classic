class DropTableAdminUsers < ActiveRecord::Migration
  def up
    drop_table :admin_users
    drop_table :active_admin_comments
  end

  def down
    create_table(:admin_users) do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip
      t.timestamps
    end
    add_index :admin_users, :email, unique: true
    add_index :admin_users, :reset_password_token, unique: true

    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text :body
      t.string :resource_id, null: false
      t.string :resource_type, null: false
      t.references :author, polymorphic: true
      t.timestamps
    end
    add_index :active_admin_comments, [:namespace]
    add_index :active_admin_comments, [:author_type, :author_id]
    add_index :active_admin_comments, [:resource_type, :resource_id]
  end
end
