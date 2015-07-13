class AddDefaultForDbType < ActiveRecord::Migration
  def change
    change_column_default :servers, :db_type, 'mysql'
  end
end
