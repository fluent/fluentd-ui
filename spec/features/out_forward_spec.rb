require "spec_helper"

describe "out_forward", stub: :daemon do
  let(:exists_user) { build(:user) }
  let(:match) { "test.out_forward.#{Time.now.to_i}.*" }

  before do
    login_with exists_user
  end

  it "Shown form" do
    visit daemon_setting_out_forward_path
    page.should have_css('input[name="setting[pattern]"]')
  end

  it "Appendable server setting", js: true do
    visit daemon_setting_out_forward_path
    all('.js-nested-column .js-append', visible: false).length.should == 1
    all('.js-append').first.click
    all('.js-nested-column .js-append', visible: false).length.should == 2
  end

  it "Updated config after submit", js: true do
    skip "Maybe validation failed"
    daemon.agent.config.should_not include(match)
    visit daemon_setting_out_forward_path
    within('form') do
      fill_in "Pattern", with: match
      fill_in "setting_server_0__host", with: "foobar"
      fill_in "setting_server_0__port", with: "9999"
      fill_in "Path", with: "/tmp/foo"
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(match)
  end
end
