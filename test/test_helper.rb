ENV['RAILS_ENV'] ||= 'test'
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start("rails")
end

require_relative '../config/environment'
require 'test/unit/rails/test_help'
require 'test/unit/rr'
require 'test/unit/capybara'
require 'capybara-screenshot/testunit' # for integration test

if ENV["TRAVIS"]
  require "chromedriver/helper"
  Chromedriver.set_version "2.35"
end

require 'webmock/test_unit'
WebMock.disable_net_connect!(allow_localhost: true)


module FixturePath
  def fixture_path(fixture_name)
    Rails.root.join("test/fixtures", fixture_name).to_s
  end

  def fixture_content(fixture_name)
    Rails.root.join("test/fixtures", fixture_name).read
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  include FixturePath
  extend FixturePath
end

Dir[Rails.root.join("test/support/**/*.rb")].each do |path|
  require(path)
end
