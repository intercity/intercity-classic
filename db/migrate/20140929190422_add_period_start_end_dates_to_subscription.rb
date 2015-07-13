class AddPeriodStartEndDatesToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_current_period_start, :datetime
    add_column :subscriptions, :stripe_current_period_end, :datetime
  end
end
