class AddCountryTinVatToSubscription < ActiveRecord::Migration
  def change
    add_column :subscriptions, :country, :string
    add_column :subscriptions, :tin, :string
    add_column :subscriptions, :vat, :integer
  end
end
