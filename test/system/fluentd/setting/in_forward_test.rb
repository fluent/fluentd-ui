require "application_system_test_case"

class InForwardTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "in_forward"
    @form_name = "port"
    @form_value = "12345"
    @daemon = stub_daemon
  end
end
