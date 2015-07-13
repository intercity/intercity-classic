class AddMaxServersToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :max_servers, :integer
  end
end
