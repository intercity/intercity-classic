# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require "dotenv"
Dotenv.load

if Rails.env.development?
  user = User.new(
    full_name: "Normal user",
    email: "test@intercity.dev",
    password: "12345678",
    admin: true
  )
  if ENV["DO_TOKEN"]
    user.digitalocean_access_token = ENV["DO_TOKEN"]
  end
  user.skip_confirmation!
  user.save!

  staff = User.new(
    full_name: "Staff user",
    email: "staff@intercity.dev",
    password: "12345678",
    staff: true,
    admin: true
  )
  staff.skip_confirmation!
  staff.save!

  Server.create!(name: "Intercity", address: "23.543.23.1", bootstrapped: true,
                stack: "passenger", owner: user,
                wizard_finished: true,
                applications: [Application.new(name: "intercity_development",
                                                domain_names: "intercity.dev")])

  Plan.create!(stripe_id: "2-servers", stripe_name: "2 Servers", active: true,
               stripe_amount: "500", stripe_currency: "USD", staff: false,
               max_servers: 3)

  Plan.create!(stripe_id: "5-servers", stripe_name: "5 Servers", active: true,
               stripe_amount: "15000", stripe_currency: "USD", staff: false,
               max_servers: 50)
end
