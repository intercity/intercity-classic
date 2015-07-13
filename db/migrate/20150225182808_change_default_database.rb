class ChangeDefaultDatabase < ActiveRecord::Migration
  def up
    change_column_default :servers, :db_type, "postgres"
  end

  def down
    change_column_default :servers, :db_type, "mysql"
  end
end
