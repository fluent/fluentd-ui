require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  setup do
    login_with(FactoryBot.build(:user))
  end

  test "no configuration" do
    visit("/")
    within("h1") do
      assert_equal("fluentd", text)
    end
    assert do
      find_link(I18n.t('terms.setup', target: 'fluentd'))
    end
    assert do
      find_link(I18n.t('terms.setup', target: 'td-agent'))
    end
  end

  test "fluentd is stop" do
    stub_daemon
    visit("/")
    assert do
      page.has_css?('h1', text: I18n.t('fluentd.show.page_title'))
    end
    assert do
      page.has_css?('h4', text: I18n.t('fluentd.common.stopped'))
    end
    assert do
      page.has_css?('h4', text: I18n.t('fluentd.common.fluentd_info'))
    end
  end

  test "fluentd is running" do
    stub_daemon(running: true)
    visit("/")
    assert do
      page.has_css?('h1', text: I18n.t('fluentd.show.page_title'))
    end
    assert do
      page.has_css?('h4', text: I18n.t('fluentd.common.running'))
    end
    assert do
      page.has_css?('h4', text: I18n.t('fluentd.common.fluentd_info'))
    end
  end
end
