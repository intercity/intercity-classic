class AddStripeStatusToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_status, :string
  end
end
