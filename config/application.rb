require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Intercity
  class Application < Rails::Application

    # Disable generating assets and helper files when using the generator
    config.generators do |g|
      g.assets = false
      g.helper = false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = true

    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths += %W(#{config.root}/app/services #{config.root}/app/forms #{config.root}/app/validators)

    config.to_prepare do
      Devise::SessionsController.layout "login"
      Devise::RegistrationsController.layout "login"
      Devise::PasswordsController.layout "login"
    end

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      "<span class=\"error\">#{html_tag}</span>".html_safe
    end

    config.active_record.raise_in_transactional_callbacks = true
    config.active_job.queue_adapter = :sidekiq
  end
end
