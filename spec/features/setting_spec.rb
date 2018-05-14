require 'spec_helper'

describe 'setting', stub: :daemon do
  let!(:exists_user) { build(:user) }
  include_context 'daemon has some config histories'
  include_context 'daemon had been started once'

  before do
    login_with exists_user

    daemon.agent.config_write 'GREAT CONFIG HERE'

    visit '/daemon/setting'
  end

  it 'shows setting' do
    page.should have_css('h1', text: I18n.t('fluentd.settings.show.page_title'))
    page.should have_link(I18n.t('terms.edit'))
    page.should have_css('pre', text: 'GREAT CONFIG HERE')
    expect(all('.row tr').count).to eq Settings.histories_count_in_preview + 1 # links to hisotries#show + 1 table header
    page.should have_link(I18n.t('fluentd.settings.show.link_to_histories'))
    page.should have_text(I18n.t('fluentd.settings.running_backup.title'))
  end

  it 'will go to histories#index' do
    click_link I18n.t('fluentd.settings.show.link_to_histories')

    page.should have_css('h1', text: I18n.t('fluentd.settings.histories.index.page_title'))
  end

  it 'will go to histories#show' do
    all('.row tr td a').first.click

    page.should have_css('h1', text: I18n.t('fluentd.settings.histories.show.page_title'))
  end

  it 'edits setting' do
    click_link I18n.t('terms.edit')

    page.should have_css('h1', text: I18n.t('fluentd.settings.edit.page_title'))
    page.should have_css('p.text-danger', text: I18n.t('terms.notice_restart_for_config_edit', brand: 'fluentd'))

    fill_in 'config', with: 'YET ANOTHER CONFIG'

    click_button I18n.t('terms.update')

    current_path.should == '/daemon/setting'
    page.should have_css('pre', text: 'YET ANOTHER CONFIG')
  end

  describe "config" do
    before do
      Fluentd::Agent::TdAgent.any_instance.stub(:dryrun).with(an_instance_of(String)).and_return(true)
      daemon.agent.config_write conf
      click_link I18n.t('terms.edit')
    end

    context "plain config" do
      let(:conf) { <<-'CONF' }
      <source>
        @type forward
      </source>
      CONF

      it 'configtest' do
        click_button I18n.t('terms.configtest')
        page.should have_css('.alert-success')
      end

      it "update & restart check" do
        click_button I18n.t('terms.update')
        daemon.agent.config.gsub("\r\n", "\n").should == conf # CodeMirror exchange \n -> \r\n
      end
    end

    context "embedded config" do
      let(:conf) { <<-'CONF' }
      <source>
        @type forward
        id "foo#{Time.now.to_s}"
      </source>
      CONF

      it 'configtest' do
        click_button I18n.t('terms.configtest')
        page.should have_css('.alert-success')
      end

      it "update & restart check" do
        click_button I18n.t('terms.update')
        daemon.agent.config.gsub("\r\n", "\n").should == conf # CodeMirror exchange \n -> \r\n
      end
    end
  end
end
