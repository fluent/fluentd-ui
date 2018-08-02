require "application_system_test_case"

class InHttpTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "in_http"
    @form_name = "port"
    @form_value = "12345"
    @daemon = stub_daemon
  end
end
