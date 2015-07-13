class RemoveStripeCustomerIdFromSubscription < ActiveRecord::Migration
  def change
    # remove_column :subscriptions, :stripe_customer_id
    add_column :users, :stripe_customer_id, :string
  end
end
