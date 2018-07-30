require "test_helper"

class UpdateCheckingTest < ActionDispatch::IntegrationTest
  setup do
    login_with(FactoryBot.build(:user))
  end

  teardown do
    FluentdUI.latest_version = ::FluentdUI::VERSION
  end

  test "show popup if newer version is available" do
    version = "9999.99"
    FluentdUI.latest_version = version
    visit root_path
    within(".alert-info") do
      assert_equal("fluentd-ui 9999.99 is available. Go to system information page", text)
    end
  end

  test "not show popup newer version is not available" do
    visit root_path
    assert do
      !page.has_css?(".alert-info")
    end
  end
end
