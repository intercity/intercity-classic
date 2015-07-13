class CreateOnboardings < ActiveRecord::Migration
  def change
    create_table :onboardings do |t|
      t.string :name
      t.string :ruby_version, null: false, default: "2.2.1"
      t.integer :db_type, default: 0, null: false
      t.integer :provider, default: 0, null: false
      t.integer :digitalocean_region, default: 0, null: false
      t.timestamps null: false
    end
  end
end
