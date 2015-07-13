class AddArchivedToServers < ActiveRecord::Migration
  def change
    add_column :servers, :archived, :boolean, default: false
  end
end
