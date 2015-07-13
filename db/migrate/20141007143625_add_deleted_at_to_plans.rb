class AddDeletedAtToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :deleted_at, :datetime
  end
end
