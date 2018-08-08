require "application_system_test_case"

require "fluent/plugin/buf_file"

class OutStdoutTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "out_stdout"
    @form_name = "pattern"
    @form_value = "stdout.**"
    @daemon = stub_daemon
  end
end
