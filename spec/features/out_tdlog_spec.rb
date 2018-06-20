require "spec_helper"

describe "out_tdlog", stub: :daemon do
  let(:exists_user) { build(:user) }
  let(:api_key) { "dummydummy" }

  before do
    login_with exists_user
  end

  it "Shown form with filled in td.*.* on match" do
    visit daemon_setting_out_tdlog_path
    page.should have_css('input[name="fluentd_setting_out_td[match]"]')
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(api_key)
    visit daemon_setting_out_tdlog_path
    within('form') do
      fill_in "Apikey", with: api_key
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(api_key)
  end
end
