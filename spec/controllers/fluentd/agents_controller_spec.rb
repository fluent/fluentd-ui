require 'spec_helper'

describe Fluentd::AgentsController do
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
  end

  describe "when the action does not succeed" do
    it "stops" do
      expect(@agent).to receive(:stop).and_return false
      put :stop
    end

    it "starts" do
      expect(@agent).to receive(:start).and_return false
      expect(@agent).to receive(:log_tail).with(1).and_return ["some message"]
      put :start
    end

    it "restarts" do
      expect(@agent).to receive(:restart).and_return false
      expect(@agent).to receive(:log_tail).with(1).and_return ["some message"]
      put :restart
    end
  end
end
