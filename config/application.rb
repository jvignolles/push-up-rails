require File.expand_path('../boot', __FILE__)

require 'rails/all'

# CSV required for URL rewriting
#require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PushUpRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    config.plugins = [:exception_notification, :all]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Paris'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.enforce_available_locales = false # Work done by controllers, syntax for sidekiq
    I18n.config.enforce_available_locales = false
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr
    I18n.locale = :fr
    # Limits available locales, even if yml exists
    config.i18n.available_locales = [:fr]

    # Custom error pages (404, 422, 500)
    config.exceptions_app = self.routes

    # URL rewriting
    # config.middleware.insert_before(Rack::Lock, Rack::Rewrite) do
    #   filename = File.join(Rails.root, 'public', 'redirections.csv')
    #   if File.exists?(filename)
    #     CSV.parse(File.read(filename), headers: false) do |row|
    #       k, v = row
    #       r301 k, v
    #     end
    #   end
    # end
  end
end
