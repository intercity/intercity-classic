class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user, index: true
      t.references :plan, index: true
      t.datetime :canceled_at

      t.timestamps
    end
  end
end
