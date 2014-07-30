require "spec_helper"

describe "out_forward" do
  let(:exists_user) { build(:user) }
  let(:daemon) { build(:fluentd, variant: "td-agent") }
  let(:match) { "test.out_forward.#{Time.now.to_i}.*" }

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

  it "Shown form" do
    visit daemon_setting_out_forward_path
    page.should have_css('input[name="fluentd_setting_out_forward[match]"]')
  end

  it "Appendable server setting", js: true do
    visit daemon_setting_out_forward_path
    all('.js-nested-column .js-append', visible: false).length.should == 1
    all('.js-append').first.click
    all('.js-nested-column .js-append', visible: false).length.should == 2
  end

  it "Updated config after submit", js: true do
    daemon.agent.config.should_not include(match)
    visit daemon_setting_out_forward_path
    within('#new_fluentd_setting_out_forward') do
      fill_in "Match", with: match
      fill_in "fluentd_setting_out_forward_server_0__host", with: "foobar"
      fill_in "fluentd_setting_out_forward_server_0__port", with: "9999"
      fill_in "Path", with: "/tmp/foo"
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(match)
  end
end
