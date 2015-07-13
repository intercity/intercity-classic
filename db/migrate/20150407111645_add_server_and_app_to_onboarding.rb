class AddServerAndAppToOnboarding < ActiveRecord::Migration
  def change
    add_reference :onboardings, :server, index: true
    add_foreign_key :onboardings, :servers
    add_reference :onboardings, :application, index: true
    add_foreign_key :onboardings, :applications
  end
end
