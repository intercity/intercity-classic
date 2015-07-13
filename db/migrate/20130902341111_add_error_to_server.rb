class AddErrorToServer < ActiveRecord::Migration
  def change
    add_column :servers, :last_error, :string
  end
end
