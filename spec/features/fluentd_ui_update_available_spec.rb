require "spec_helper"

describe "fluentd-ui updates checking" do
  let(:exists_user) { build(:user) }
  before { login_with(exists_user) }

  describe "Show popup if newer version is available" do
    let(:version) { "9999.99" }
    let(:message) { I18n.t("messages.available_new_fluentd_ui", version: FluentdUI.latest_version, update_url: misc_information_path, title: "dummy") }
    before { FluentdUI.latest_version = version }
    after { FluentdUI.latest_version = ::FluentdUI::VERSION }

    it do
      visit root_path
      page.should have_css('.alert-info')
      page.should have_content(version)
      page.body.should include(message)
    end
  end

  describe "Not shown popup if newer version is not available" do
    let(:version) { ::FluentdUI::VERSION }
    let(:message) { I18n.t("messages.available_new_fluentd_ui", version: FluentdUI.latest_version, update_url: misc_information_path, title: "dummy") }

    it do
      visit root_path
      page.should_not have_css('.alert-info')
      page.should_not have_content(version)
      page.body.should_not include(message)
    end
  end

end
