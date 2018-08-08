require "test_helper"

class Setting < ActionDispatch::IntegrationTest
  include ::ConfigHistories::DaemonHaveSomeConfigHistories
  include ::ConfigHistories::DaemonHadBeenStartedOnce

  setup do
    login_with(FactoryBot.build(:user))
    stub_daemon
    daemon.agent.config_write("GREAT CONFIG HERE")

    visit("/daemon/setting")
  end

  test "show setting" do
    assert do
      page.has_css?('h1', text: I18n.t('fluentd.settings.show.page_title'))
    end
    assert do
      page.has_link?(I18n.t('terms.edit'))
    end
    assert do
      page.has_css?('pre', text: 'GREAT CONFIG HERE')
    end
    assert_equal(Settings.histories_count_in_preview + 1, all('.row tr').count) # links to hisotries#show + 1 table header
    assert do
      page.has_link?(I18n.t('fluentd.settings.show.link_to_histories'))
    end
    assert do
      page.has_text?(I18n.t('fluentd.settings.running_backup.title'))
    end
  end

  test "go to histories#index" do
    click_link(I18n.t('fluentd.settings.show.link_to_histories'))

    assert do
      page.has_css?('h1', text: I18n.t('fluentd.settings.histories.index.page_title'))
    end
  end

  test "go to histories#show" do
    all('.row tr td a').first.click

    assert do
      page.has_css?('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))
    end
  end

  test "edit setting" do
    click_link(I18n.t('terms.edit'))

    assert do
      page.has_css?('h1', text: I18n.t('fluentd.settings.edit.page_title'))
    end
    assert do
      page.has_css?('p.text-danger', text: I18n.t('terms.notice_restart_for_config_edit', brand: 'fluentd'))
    end

    fill_in('config', with: 'YET ANOTHER CONFIG')

    click_button(I18n.t('terms.update'))

    assert_equal('/daemon/setting', current_path)
    assert do
      page.has_css?('pre', text: 'YET ANOTHER CONFIG')
    end
  end

  sub_test_case "plain config" do
    setup do
      any_instance_of(Fluentd::Agent::TdAgent) do |object|
        @conf = <<-'CONFIG'
        <source>
          @type forward
        </source>
        CONFIG
        stub(object).dryrun(anything) { true }
        daemon.agent.config_write(@conf)
        click_link(I18n.t('terms.edit'))
      end
    end

    test "configtest" do
      click_button(I18n.t('terms.configtest'))
      assert do
        page.has_css?('.alert-success')
      end
    end

    test "update & restart check" do
      click_button(I18n.t('terms.update'))
      # CodeMirror exchange \n -> \r\n
      assert_equal(@conf, daemon.agent.config.gsub("\r\n", "\n"))
    end
  end

  sub_test_case "embedded config" do
    setup do
      any_instance_of(Fluentd::Agent::TdAgent) do |object|
        @conf = <<-'CONFIG'
        <source>
          type forward
          id "foo#{Time.now.to_s}"
        </source>
        CONFIG
        stub(object).dryrun(anything) { true }
        daemon.agent.config_write(@conf)
        click_link(I18n.t('terms.edit'))
      end
    end

    test "configtest" do
      click_button(I18n.t('terms.configtest'))
      assert do
        page.has_css?('.alert-success')
      end
    end

    test "update & restart check" do
      click_button(I18n.t('terms.update'))
      # CodeMirror exchange \n -> \r\n
      assert_equal(@conf, daemon.agent.config.gsub("\r\n", "\n"))
    end
  end
end
