ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'test/unit/rails/test_help'
require 'test/unit/rr'
require 'webmock/test_unit'

WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def fixture_path(fixture_name)
    Rails.root.join("test/fixtures", fixture_name).to_s
  end
end
