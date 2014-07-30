require "spec_helper"

describe "out_td" do
  let(:exists_user) { build(:user) }
  let(:daemon) { build(:fluentd, variant: "td-agent") }
  let(:api_key) { "dummydummy" }

  before do
    Fluentd.stub(:instance).and_return(daemon)
    Fluentd::Agent::TdAgent.any_instance.stub(:detached_command).and_return(true)
    daemon.agent.config_write ""
    
    visit '/sessions/new'
    within("form") do
      fill_in 'session_name', :with => exists_user.name
      fill_in 'session_password', :with => exists_user.password
    end
    click_button I18n.t("terms.sign_in")
  end

  it "Shown form with filled in td.*.* on match" do
    visit daemon_setting_out_td_path
    page.should have_css('input[name="fluentd_setting_out_td[match]"]')
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(api_key)
    visit daemon_setting_out_td_path
    within('#new_fluentd_setting_out_td') do
      fill_in "Apikey", with: api_key
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(api_key)
  end
end
