require "spec_helper"

describe "histories", stub: :daemon do
  let!(:exists_user) { build(:user) }
  include_context 'daemon has some config histories'

  before do
    login_with exists_user
  end

  describe 'index' do
    before do
      visit '/daemon/setting/histories'
    end

    it 'show histories#index' do
      page.should have_css('h1', text: I18n.t('fluentd.settings.histories.index.page_title'))
      expect(all('.row tr').count).to eq 9 + 1 # links to hisotries#show + 1 table header
    end

    it 'will go to histories#show' do
      all('.row tr td a').first.click

      page.should have_css('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))
    end
  end

  describe 'show' do
    let!(:last_backup_file) { Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order.first) }
    let!(:new_file) { Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order[1]) }

    before do
      visit "/daemon/setting/histories/#{last_backup_file.file_id}"
    end

    it 'show histories#show' do
      page.should have_css('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))

      page.should has_text?(last_backup_file.content)
    end

    describe 'diff' do
      context 'has diff' do
        it 'shows diff between current and target' do
          page.should has_text?("-   type http")
          page.should has_text?("+   type forward")
          page.should has_text?("-   port 8899")
          page.should has_text?("+   port 24224")
        end
      end

      context 'has no diff' do
        before do
          visit "/daemon/setting/histories/#{new_file.file_id}"
        end

        it 'shows no diff message' do
          page.should have_text(I18n.t('messages.no_diff'))
        end
      end
    end

    it 'update config and redirect to setting#show' do
      click_link I18n.t("terms.reuse")

      page.should have_css('h1', text: I18n.t('fluentd.settings.show.page_title'))
      page.should have_text(I18n.t('messages.config_successfully_copied', brand: 'fluentd') )
      page.should has_text?(last_backup_file.content)
    end

    describe "configtest" do
      let(:daemon) { build(:fluentd, variant: "fluentd_gem") } # To use fluentd_gem for real dry-run checking
      before do
        daemon.agent.config_write config
        daemon.agent.config_write "# dummy"
        backup = Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order.first)
        visit "/daemon/setting/histories/#{backup.file_id}"
        click_link I18n.t("terms.configtest")
      end

      context "invalid configfile" do
        let(:config) { <<-CONFIG }
        <source>
          type aaaaaaaaaaaa
        </source>
        CONFIG

        it do
          page.should_not have_css('.alert-success')
          page.should have_css('.alert-danger')
          page.should have_text(%Q|Unknown input plugin 'aaaaaaaaaaaa'|)
        end
      end

      context "valid configfile" do
        let(:config) { <<-CONFIG }
        <source>
          type syslog
          tag syslog
        </source>
        CONFIG

        it do
          page.should have_css('.alert-success')
          page.should_not have_css('.alert-danger')
        end
      end
    end
  end
end
