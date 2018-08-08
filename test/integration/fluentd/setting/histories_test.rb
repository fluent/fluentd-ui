require "test_helper"

class HistoriesTest < ActionDispatch::IntegrationTest
  include ConfigHistories::DaemonHaveSomeConfigHistories

  setup do
    login_with(FactoryBot.build(:user))
  end

  sub_test_case "index" do
    setup do
      visit("/daemon/setting/histories")
    end

    test "show histories#index" do
      assert do
        page.has_css?("h1", text: I18n.t("fluentd.settings.histories.index.page_title"))
      end
      # links to hisotries#show + 1 table header
      assert_equal(10, all(".row tr").count)
    end

    test "go to histories#show" do
      all(".row tr td a").first.click

      assert do
        page.has_css?("h1", text: I18n.t("fluentd.settings.histories.show.page_title"))
      end
    end
  end

  sub_test_case "show" do
    setup do
      @last_backup_file = Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order.first)
      @new_file = Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order[1])
    end

    sub_test_case "with diff" do
      setup do
        visit("/daemon/setting/histories/#{@last_backup_file.file_id}")
      end

      test "show histories#show" do
        assert do
          page.has_css?("h1", text: I18n.t("fluentd.settings.histories.show.page_title"))
        end
        doc = Nokogiri.HTML(page.source)
        assert_equal(@last_backup_file.content.strip, doc.search("pre").first.text)
      end

      test "shows diff between current and target" do
        within(".diff pre") do
          [
            "- @type http",
            "+ @type forward",
            "- port 8899",
            "+ port 24224"
          ].each do |text|
            assert do
              has_text?(text)
            end
          end
        end
      end

      test "update config and redirect to setting#show" do
        click_link(I18n.t("terms.reuse"))

        assert do
          page.has_css?("h1", text: I18n.t("fluentd.settings.show.page_title"))
        end
        assert do
          page.has_text?(I18n.t("messages.config_successfully_copied", brand: "fluentd") )
        end
        assert_equal("/daemon/setting", page.current_path)
      end
    end

    sub_test_case "without diff" do
      setup do
        visit("/daemon/setting/histories/#{@new_file.file_id}")
      end

      test "shows no diff message" do
        assert do
          page.has_text?(I18n.t("messages.no_diff"))
        end
      end
    end

    sub_test_case "configtest" do
      setup do
        # To use fluentd_gem for real dry-run checking
        @daemon = FactoryBot.build(:fluentd, variant: "fluentd_gem")
      end

      def config_test(config)
        daemon.agent.config_write config
        daemon.agent.config_write "# dummy"
        backup = Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order.first)
        visit("/daemon/setting/histories/#{backup.file_id}")
        click_link(I18n.t("terms.configtest"))
      end

      test "invalid config" do
        config_test(<<-CONFIG)
          <source>
            @type no_such_plugin
          </source>
        CONFIG
        assert do
          !page.has_css?('.alert-success')
        end
        assert do
          page.has_css?('.alert-danger')
        end
        assert do
          page.has_text?(%Q|Unknown input plugin 'no_such_plugin'|)
        end
      end

      test "valid config" do
        config_test(<<-CONFIG)
          <source>
            @type syslog
            tag syslog
          </source>
        CONFIG

        assert do
          page.has_css?('.alert-success')
        end
        assert do
          !page.has_css?('.alert-danger')
        end
      end
    end
  end
end
