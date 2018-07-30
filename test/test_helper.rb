ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'test/unit/rails/test_help'
require 'test/unit/rr'
require 'test/unit/capybara'
require 'webmock/test_unit'

WebMock.disable_net_connect!(allow_localhost: true)


module FixturePath
  def fixture_path(fixture_name)
    Rails.root.join("test/fixtures", fixture_name).to_s
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  include FixturePath
  extend FixturePath
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app,
    browser: :chrome,
    desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
      chrome_options: {
        args: %w(headless disable-gpu window-size=1920,1080),
      },
    )
  )
end

Capybara.javascript_driver = :selenium
require "capybara-screenshot/testunit"

Dir[Rails.root.join("test/support/**/*.rb")].each do |path|
  require(path)
end
