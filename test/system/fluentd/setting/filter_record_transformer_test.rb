require "application_system_test_case"

class FilterRecordTransformerTest < ApplicationSystemTestCase
  setup do
    login_with(FactoryBot.build(:user))
    @daemon = stub_daemon
  end

  test "show form" do
    visit(daemon_setting_filter_record_transformer_path)
    assert do
      page.has_css?("textarea[name=\"setting[record]\"]")
    end
  end

  test "update config" do
    value = "key value"
    assert do
      !@daemon.agent.config.include?(value)
    end
    visit(daemon_setting_filter_record_transformer_path)
    within("form") do
      fill_in("Record", with: value)
    end
    click_button(I18n.t("fluentd.common.finish"))
    assert do
      @daemon.agent.config.include?(value)
    end
  end
end
