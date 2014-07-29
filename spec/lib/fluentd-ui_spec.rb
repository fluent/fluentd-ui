require 'spec_helper'

describe FluentdUI do
  describe ".update_available?" do
    let(:current_version) { ::FluentdUI::VERSION }
    before { FluentdUI.latest_version = latest_version }
    subject { FluentdUI.update_available? }

    context "nothing" do
      let(:latest_version) { current_version }
      it { should be_falsey }
    end

    context "available" do
      let(:latest_version) { current_version.succ }
      it { should be_truthy }
    end
  end

  describe ".fluentd_version" do
    before { Fluentd.stub(:instance).and_return(target) }
    subject { FluentdUI.fluentd_version }

    context "not setup yet" do
      let(:target) { nil }
      it { should be_nil }
    end

    context "did setup" do
      let(:target) { build(:fluentd) }
      let(:version) { "1.1.1" }
      it { should == target.agent.version }
    end
  end
end
