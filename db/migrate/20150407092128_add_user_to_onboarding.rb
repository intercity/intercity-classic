class AddUserToOnboarding < ActiveRecord::Migration
  def change
    add_reference :onboardings, :user, index: true
    add_foreign_key :onboardings, :users
  end
end
