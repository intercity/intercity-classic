class CreateEnvVars < ActiveRecord::Migration
  def change
    create_table :env_vars do |t|
      t.belongs_to :application
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
