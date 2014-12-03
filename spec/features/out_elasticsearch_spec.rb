require "spec_helper"

describe "out_elasticsearch", stub: :daemon do
  let(:exists_user) { build(:user) }
  let(:match) { "test.out_forward.#{Time.now.to_i}.*" }
  let(:location) { daemon_setting_out_elasticsearch_path }

  before do
    login_with exists_user
  end

  it "Shown form" do
    visit location
    page.should have_css('input[name="fluentd_setting_out_elasticsearch[match]"]')
  end

  it "Updated config after submit", js: true do
    daemon.agent.config.should_not include(match)
    visit location
    within('#new_fluentd_setting_out_elasticsearch') do
      fill_in "Match", with: match
      fill_in "Index name", with: "index"
      fill_in "Type name", with: "type_name"
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(match)
  end
end
