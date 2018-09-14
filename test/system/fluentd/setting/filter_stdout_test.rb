require "application_system_test_case"

class FilterStdoutTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "filter_stdout"
    @form_name = "pattern"
    @form_value = "stdout.**"
    @daemon = stub_daemon
  end
end
