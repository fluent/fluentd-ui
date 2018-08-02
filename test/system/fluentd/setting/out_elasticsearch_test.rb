require "application_system_test_case"

class OutElasticsearchTest < ApplicationSystemTestCase
  setup do
    login_with(FactoryBot.build(:user))
    @daemon = stub_daemon
    @pattern = "test.out_forward.#{Time.now.to_i}.*"
  end

  test "show form" do
    visit(daemon_setting_out_elasticsearch_path)
    assert do
      page.has_css?('input[name="setting[pattern]"]')
    end
  end

  test "Update config" do
    assert do
      !@daemon.agent.config.include?(@pattern)
    end
    visit(daemon_setting_out_elasticsearch_path)
    within("form") do
      fill_in("Pattern", with: @pattern)
      fill_in("Index name", with: "index")
      fill_in("Type name", with: "type_name")
    end
    click_button(I18n.t("fluentd.common.finish"))
    assert do
      @daemon.agent.config.include?(@pattern)
    end
  end
end
