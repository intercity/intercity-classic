class AddStackToServers < ActiveRecord::Migration
  def change
    change_table :servers do |t|
      t.string :stack, default: 'rails'
    end
  end
end
