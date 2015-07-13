class CreateSshKeys < ActiveRecord::Migration
  def change
    create_table :ssh_keys do |t|
      t.string :name
      t.text :key
      t.belongs_to :server

      t.timestamps
    end
  end
end
