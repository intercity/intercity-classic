class AddStripeSubscriptionIdToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_subscription_id, :string
  end
end
