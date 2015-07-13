class AddAppliedAtToServers < ActiveRecord::Migration
  def change
    add_column :servers, :applied_at, :datetime
  end
end
