class AddDefaultToServerName < ActiveRecord::Migration
  def change
    change_column_null :servers, :name, false, 'Unnamed Server'
  end
end
