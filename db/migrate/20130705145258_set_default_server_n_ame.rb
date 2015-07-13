class SetDefaultServerNAme < ActiveRecord::Migration
  def change
    change_column_default :servers, :name, 'Unnamed Server'
  end
end
