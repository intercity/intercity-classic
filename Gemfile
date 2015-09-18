source 'https://rubygems.org'

gem 'rails', '4.2.2'
gem "pg", "~> 0.18.2"
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder'
gem 'font-awesome-rails', '~> 4.1'
gem 'normalize-rails', '~> 2.1.1'
gem 'neat', '~> 1.6.0'
gem 'bitters', '~> 0.10.1'
gem 'net-ssh', '~> 2.6'
gem 'sshkey', '~> 1.5.1'
gem "fog"
gem 'rollbar', '~> 1.0.0'
gem 'knife-solo', github: 'intercity/knife-solo', branch: 'nodes-out-of-kitchen'
gem 'sinatra', '>= 1.3.0', require: nil
gem 'sidekiq', '~> 3.2.5'
gem 'sidekiq-status', '~> 0.5.2'
gem "redis", '~> 3.1.0'
gem "redis-namespace", "~> 1.5.1"
gem "flipper", "~> 0.7.0.beta6"
gem "flipper-redis", "~> 0.7.0.beta6"
gem "flipper-ui"
gem 'geoip'
gem 'stripe', '~> 1.16.0'
gem 'sass-rails', '~> 5.0.0.beta1'
gem "devise", "~> 3.4.1"
gem "intercom-rails", "~> 0.2.24"
gem "whenever", require: false
gem "droplet_kit", github: "jvanbaarsen/droplet_kit", branch: "bumped-as"
gem 'nprogress-rails', '~> 0.1.6.3'
gem "rails_admin"
gem "appsignal"
gem 'paranoia', '~> 2.1.0'
gem "polarssl", "~> 1.0.2"
gem "magnific-popup-rails"
gem "settingslogic"

gem "passenger", group: :passenger

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'traceroute'
  gem 'quiet_assets'
  gem "rubocop"
  gem "brakeman", :require => false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'guard'
  gem 'guard-minitest'
  gem "guard-rubocop"
  gem 'spring', '~> 1.1.3'
  gem 'foreman'
  gem 'daemon_controller'
  gem 'rb-fsevent'
  gem 'web-console'
end

group :test do
  gem "minitest-rails-capybara"
  gem "minitest-reporters"
  gem 'timecop'
  gem 'shoulda'
  gem 'mocha'
  gem "launchy"
  gem 'rack_session_access'
  gem "poltergeist"
  gem "database_cleaner"
end
