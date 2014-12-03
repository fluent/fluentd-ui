require "spec_helper"

describe "in_monitor_agent", stub: :daemon do
  let(:port) { "12345" }

  before { login_with exists_user }

  it "Shown form with filled in td.*.* on match" do
    visit daemon_setting_in_monitor_agent_path
    page.should have_css('input[name="fluentd_setting_in_monitor_agent[port]"]')
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(port)
    visit daemon_setting_in_monitor_agent_path
    within('#new_fluentd_setting_in_monitor_agent') do
      fill_in "Port", with: port
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(port)
  end
end
