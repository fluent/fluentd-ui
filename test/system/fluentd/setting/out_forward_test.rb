require "application_system_test_case"
require "fluent/plugin/buf_file"

class OutForwardTest < ApplicationSystemTestCase
  setup do
    login_with(FactoryBot.build(:user))
    @daemon = stub_daemon
    @pattern = "test.out_forward.#{Time.now.to_i}.*"
  end

  test "show form" do
    visit(daemon_setting_out_forward_path)
    assert do
      page.has_css?('input[name="setting[pattern]"]')
    end
  end

  test "appendable server setting" do
    visit(daemon_setting_out_forward_path)
    assert_equal(1, all(".js-nested-column .js-append", visible: false).size)
    all('.js-append').first.click
    assert_equal(2, all(".js-nested-column .js-append", visible: false).size)
  end

  test "update config" do
    assert do
      !@daemon.agent.config.include?(@pattern)
    end
    visit(daemon_setting_out_forward_path)
    within("form") do
      fill_in("Pattern", with: @pattern)
      fill_in("setting_server_0__host", with: "localhost")
      fill_in("setting_server_0__port", with: "9999")
      fill_in("Path", with: "/tmp/foo")
    end
    click_button(I18n.t("fluentd.common.finish"))
    assert do
      @daemon.agent.config.include?(@pattern)
    end
  end
end
