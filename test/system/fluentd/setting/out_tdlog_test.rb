require "application_system_test_case"

require "fluent/plugin/buf_file"

class OutTdlogTest < ApplicationSystemTestCase
  include ConfigurableDaemonSettings

  setup do
    login_with(FactoryBot.build(:user))
    @type = "out_tdlog"
    @form_name = "apikey"
    @form_value = "dummydummy"
    @daemon = stub_daemon
  end
end
