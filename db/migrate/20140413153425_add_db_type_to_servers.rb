class AddDbTypeToServers < ActiveRecord::Migration
  def change
    add_column :servers, :db_type, :string, default: 'mysql'
  end
end
