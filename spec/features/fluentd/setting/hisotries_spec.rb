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
      expect(all('.row li').count).to eq 9 #links to hisotries#show
    end

    it 'will go to histories#show' do
      all('.row li a').first.click

      page.should have_css('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))
    end
  end

  describe 'show' do
    let(:last_backup_file) { Fluentd::SettingArchive::BackupFile.new(daemon.agent.backup_files_in_new_order.first) }

    before do
      visit "/daemon/setting/histories/#{last_backup_file.file_id}"
    end

    it 'show histories#show' do
      page.should have_css('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))
      page.should have_text(last_backup_file.content)
    end

    it 'update config and redirect to setting#show' do
      click_link I18n.t("terms.reuse")

      page.should have_css('h1', text: I18n.t('fluentd.settings.show.page_title'))
      page.should have_text(I18n.t('messages.config_successfully_copied', brand: 'fluentd') )
      page.should have_text(last_backup_file.content)
    end
  end
end
