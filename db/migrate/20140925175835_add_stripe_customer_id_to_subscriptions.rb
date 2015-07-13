class AddStripeCustomerIdToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :stripe_customer_id, :string, after: :plan_id
  end
end
