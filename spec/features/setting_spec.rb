require 'spec_helper'

describe 'setting', stub: :daemon do
  let!(:exists_user) { build(:user) }

  before do
    login_with exists_user

    daemon.agent.config_write 'GREAT CONFIG HERE'

    visit '/daemon/setting'
  end

  it 'shows setting' do
    page.should have_css('h1', text: I18n.t('fluentd.settings.show.page_title'))
    page.should have_link(I18n.t('terms.edit'))
    page.should have_css('pre', text: 'GREAT CONFIG HERE')
  end

  it 'edits setting' do
    click_link I18n.t('terms.edit')

    page.should have_css('h1', text: I18n.t('fluentd.settings.edit.page_title'))
    page.should have_css('p.text-danger', text: I18n.t('terms.notice_restart_for_config_edit', brand: 'fluentd'))

    fill_in 'config', with: 'SUPER GREAT CONFIG HERE'

    click_button I18n.t('terms.update')

    current_path.should == '/daemon/setting'
    page.should have_css('pre', text: 'SUPER GREAT CONFIG HERE')
  end
end
