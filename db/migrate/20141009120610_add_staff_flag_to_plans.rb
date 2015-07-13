class AddStaffFlagToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :staff, :boolean, default: false
  end
end
