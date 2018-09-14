require "application_system_test_case"

class FilterParserTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "filter_parser"
    @form_name = "key_name"
    @form_value = "message"
    @daemon = stub_daemon
  end
end
