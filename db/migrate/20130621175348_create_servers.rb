class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :name
      t.string :address
      t.boolean :bootstrapped

      t.text :rsa_key
      t.text :mysql_passwords
      t.string :username
      t.integer :ssh_port, default: 22

      t.belongs_to :owner, null: false

      t.timestamps
    end
  end
end
