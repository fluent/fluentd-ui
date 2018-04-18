if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
require 'capybara-screenshot/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/*/shared_examples/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Syntax sugar to use the FactoryBot methods directly instead FactoryBot.create ete.
  config.include FactoryBot::Syntax::Methods
  config.include LoginMacro
  config.include JavascriptMacro
  config.include StubDaemon
  config.include ConfigHistories

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # allow `should`
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  # rspec 2.99
  config.infer_spec_type_from_file_location!

  unless File.directory?("/opt/td-agent")
    # including td-agent specific tests, so some tests will fail if the system has no td-agent
    warn "\n\nSkipping td-agent specific tests (system has no td-agent)\n\n"
    config.filter_run_excluding :td_agent_required => true
  end

  config.after(:suite) do
    FileUtils.rm_rf FluentdUI.data_dir
  end
end
