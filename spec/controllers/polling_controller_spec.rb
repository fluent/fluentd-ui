require 'spec_helper'

describe PollingController do
  describe 'polling for alerts' do
    before do
      allow(controller).to receive(:current_user).and_return true
    end

    after do
      response.should be_success
    end

    it 'may find nothing' do
      expect(controller).to receive(:uninstalling_gems).and_return []
      expect(controller).to receive(:installing_gems).and_return []
      get :alerts
    end

    it 'may find gems being uninstalled' do
      expect(controller).to receive(:uninstalling_gems).and_return [
        double(gem_name: "foobar", version: "1.0.0")
      ]

      allow(controller).to receive(:installing_gems).and_return []

      get :alerts
    end

    it 'may find gems being installed' do
      expect(controller).to receive(:installing_gems).and_return [
        double(gem_name: "bazbang", version: "0.0.1")
      ]

      allow(controller).to receive(:uninstalling_gems).and_return []

      get :alerts
    end
  end
end
