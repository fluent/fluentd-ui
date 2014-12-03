require 'spec_helper'

describe 'dashboard' do
  let!(:exists_user) { build(:user) }

  before { login_with exists_user }

  context 'no configuration' do
    before { visit '/' }

    it do
      page.should have_css('h1', text: 'fluentd')
      page.should have_link(I18n.t('terms.setup', target: 'fluentd'))
      page.should have_link(I18n.t('terms.setup', target: 'td-agent'))
    end
  end

  context 'fluentd is stop', stub: :daemon do
    before do
      visit '/'
    end

    it do
      page.should have_css('h1', text: I18n.t('fluentd.show.page_title'))
      page.should have_css('h4', text: I18n.t('fluentd.common.stopped'))
      page.should have_css('h4', text: I18n.t('fluentd.common.fluentd_info'))
    end
  end

  context 'fluentd is running', stub: :daemon do
    before do
      # XXX i have no idea to not use stub...
      Fluentd::Agent::TdAgent.any_instance.stub(:running?).and_return(true)

      visit '/'
    end

    it do
      page.should have_css('h1', text: I18n.t('fluentd.show.page_title'))
      page.should have_css('h4', text: I18n.t('fluentd.common.running'))
      page.should have_css('h4', text: I18n.t('fluentd.common.fluentd_info'))
    end
  end
end
