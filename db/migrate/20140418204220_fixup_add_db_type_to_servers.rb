require_relative '20140413153425_add_db_type_to_servers.rb'

class FixupAddDbTypeToServers < ActiveRecord::Migration
  def change
    revert AddDbTypeToServers
    add_column :servers, :db_type, :string
  end
end
