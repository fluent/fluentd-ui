require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
# require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# these gems are not required by Bundler.require
require "font-awesome-rails"
require "draper"
require "sass"
require "haml-rails"
require "jquery-rails"
require "sucker_punch"
require "settingslogic"
require "kramdown-haml"
require "jbuilder"
require "diff/lcs"
require "webpacker"

module FluentdUi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = 'en'
    config.i18n.available_locales = %i(en ja)
    config.autoload_paths += %W(#{config.root}/lib)

    config.active_job.queue_adapter = :sucker_punch

    # NOTE: currently, fluentd-ui does not using ActiveRecord, and using Time.now instead of Time.zone.now for each different TZ for users.
    #       If AR will be used, please comment in and check timezone.
    # config.active_record.default_timezone = :local
    # config.time_zone =

    require Rails.root.join("lib", "fluentd-ui")

    if ENV["FLUENTD_UI_LOG_PATH"].present?
      config.logger = ActiveSupport::Logger.new(ENV["FLUENTD_UI_LOG_PATH"])
    end
  end
end
