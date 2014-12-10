require 'spec_helper'

describe 'dashboard' do
  let!(:exists_user) { build(:user) }

  before { login_with exists_user }

  context 'no configuration' do
    before { visit '/' }

    it do
      page.should_not have_css(".fluentd-status")
    end
  end

  context 'fluentd is stop', stub: :daemon do
    before { visit '/' }

    it do
      page.should have_css(".fluentd-status .stopped")
    end
  end

  context 'fluentd is running', stub: :daemon do
    before do
      # XXX i have no idea to not use stub...
      Fluentd::Agent::TdAgent.any_instance.stub(:running?).and_return(true)

      visit '/'
    end

    it do
      page.should have_css(".fluentd-status .running")
    end
  end
end
