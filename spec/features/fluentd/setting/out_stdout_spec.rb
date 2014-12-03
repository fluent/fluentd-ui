require "spec_helper"

describe "out_stdout", stub: :daemon do
  let(:match) { "stdout.**" }

  before { login_with exists_user }

  it "Shown form with filled in td.*.* on match" do
    visit daemon_setting_out_stdout_path
    page.should have_css('input[name="fluentd_setting_out_stdout[match]"]')
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(match)
    visit daemon_setting_out_stdout_path
    within('#new_fluentd_setting_out_stdout') do
      fill_in "Match", with: match
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(match)
  end
end
