class AddTypeToServer < ActiveRecord::Migration
  def change
    add_column :servers, :provider, :integer, default: 0
  end
end
