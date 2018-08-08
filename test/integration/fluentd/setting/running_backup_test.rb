require "test_helper"

class RunningBackupTest < ActionDispatch::IntegrationTest
  include ConfigHistories::DaemonHaveSomeConfigHistories

  setup do
    login_with(FactoryBot.build(:user))
  end

  sub_test_case "have no running backup files" do
    test "have no contents, no reuse button" do
      visit("/daemon/setting/running_backup")
      assert do
        page.has_text?(I18n.t('fluentd.common.never_started_yet', brand: 'fluentd'))
      end
      assert do
        !page.has_css?("pre")
      end
      assert do
        !page.has_text?(I18n.t("terms.reuse"))
      end
    end
  end

  sub_test_case "have running backup files" do
    include ConfigHistories::DaemonHadBeenStartedOnce

    setup do
      visit("/daemon/setting/running_backup")
    end

    test "have content and reuse button" do
      assert do
        !page.has_text?(I18n.t('fluentd.common.never_started_yet', brand: 'fluentd'))
      end
      assert do
        page.has_text?(backup_content)
      end
      assert do
        page.has_text?(I18n.t("terms.reuse"))
      end
    end

    test "have diff" do
      diff = page.first(".diff pre").native.inner_text
      assert_equal(<<-DIFF.gsub("\n\n", ""), diff)

  - <source>
  + Running backup file content
  -   @type http
  -   port 8899
  - </source>
  \n
      DIFF
    end

    test "have no diff" do
      daemon.agent.config_write(backup_content)
      visit("/daemon/setting/running_backup")
      assert do
        page.has_text?(I18n.t('messages.no_diff'))
      end
    end
  end
end
