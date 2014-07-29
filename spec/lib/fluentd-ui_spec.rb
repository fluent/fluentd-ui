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
end
