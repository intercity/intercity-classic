class RemoveDefaultFromServerName < ActiveRecord::Migration
  def change
    change_column_default :servers, :name, nil
  end
end
