require 'spec_helper'

describe Fluentd::AgentsController do
  let(:log) { double('log').as_null_object }

  before do
    allow(controller).to receive(:current_user).and_return true
    allow(controller).to receive(:find_fluentd).and_return(nil)
    controller.instance_variable_set(:@fluentd, double(agent: @agent = double(:agent)))
  end

  describe "when the action succeeds" do
    it "stops" do
      expect(@agent).to receive(:stop).and_return true
      put :stop
    end

    it "starts" do
      expect(@agent).to receive(:start).and_return true
      put :start
    end

    it "restarts" do
      expect(@agent).to receive(:restart).and_return true
      put :restart
    end

    it "reaload" do
      expect(@agent).to receive(:reload).and_return true
      put :reload
    end
  end

  describe "when the action does not succeed" do
    it "stops" do
      expect(@agent).to receive(:stop).and_return false
      put :stop
    end

    it "starts" do
      expect(@agent).to receive(:start).and_return false
      expect(@agent).to receive(:log).and_return(log)
      expect(log).to receive(:tail).with(1)
      put :start
    end

    it "restarts" do
      expect(@agent).to receive(:restart).and_return false
      expect(@agent).to receive(:log).and_return(log)
      expect(log).to receive(:tail).with(1)
      put :restart
    end

    it "reload" do
      expect(@agent).to receive(:reload).and_return false
      expect(@agent).to receive(:log).and_return(log)
      expect(log).to receive(:tail).with(1)
      put :reload
    end
  end
end
