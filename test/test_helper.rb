ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'sidekiq/testing'
require 'minitest/mock'
require "mocha/mini_test"
require "minitest/rails"
require "minitest/rails/capybara"
require "minitest/reporters"
require "support/ssl_helper"
require "rack_session_access/capybara"
require "capybara/poltergeist"
require 'database_cleaner'

Sidekiq::Testing.fake!

Minitest::Reporters.use!(
  Minitest::Reporters::DefaultReporter.new(color: true),
  ENV, Minitest.backtrace_filter
)

DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  include SslHelper
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all
  self.use_transactional_fixtures = false

  # Add more helper methods to be used by all tests here...

  def setup
    Sidekiq::Worker.clear_all
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end

class Capybara::Rails::TestCase
  include Warden::Test::Helpers
  Warden.test_mode!
  Capybara.javascript_driver = :poltergeist
  DatabaseCleaner.clean_with :truncation
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: true, timeout: 90)
  end

  def use_javascript_driver
    Capybara.current_driver = Capybara.javascript_driver
  end

  def teardown
    Capybara.current_driver = nil
  end
end

EncryptedValue.encryption_key = 'f3fd12e9f3cef8ec5d508b26afbdafa2'
