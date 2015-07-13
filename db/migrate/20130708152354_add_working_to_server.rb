class AddWorkingToServer < ActiveRecord::Migration
  def change
    add_column :servers, :working, :boolean, default: false
  end
end
