class AddDbHostAndName < ActiveRecord::Migration
  def change
    add_column :applications, :database_host, :string, default: 'localhost'
    add_column :applications, :database_name, :string

    Application.update_all('database_name = name')
  end
end
