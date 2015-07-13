class AddAmountToPlan < ActiveRecord::Migration
  def change
    add_column :plans, :stripe_amount, :integer
    add_column :plans, :stripe_currency, :string
  end
end
