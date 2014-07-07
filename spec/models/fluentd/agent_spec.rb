require 'spec_helper'

describe Fluentd::Agent do
  let(:instance) { described_class.new(options) }
  let(:options) { {} }

  describe "FluentdGem" do
    let(:described_class) { Fluentd::Agent::FluentdGem } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Fluentd::Agent has common behavior"

    describe "#options_to_argv" do
      subject { instance.send(:options_to_argv) }
      it { should include("-c #{instance.config_file}") }
      it { should include("-d #{instance.pid_file}") }
      it { should include("-o #{instance.log_file}") }
      it { should include("--use-v1-config") }
    end

    describe "#start" do
      before { instance.stub(:running?).and_return(running) }

      context "running" do
        let(:running) { true }

        subject { instance.start }

        it { should be_truthy }
      end

      context "not running" do
        let(:running) { false }

        subject { instance.start }

        before do
          instance.stub(:actual_start).and_return(start_result)
        end

        context "actual start success" do
          let(:start_result) { true }
          it { should be_truthy }
        end

        context "actual start failed" do
          let(:start_result) { false }
          it { should be_falsy }
        end
      end
    end

    describe "#stop" do
      before { instance.stub(:running?).and_return(running) }

      subject { instance.stop }

      context "running" do
        let(:running) { true }

        before { instance.stub(:actual_stop).and_return(stop_result) }

        context "actual stop success" do
          let(:stop_result) { true }
          it { should be_truthy }
        end

        context "actual stop failed" do
          let(:stop_result) { false }
          it { should be_falsy }
        end
      end

      context "not running" do
        let(:running) { false }

        it { should be_truthy }
      end
    end

    describe "#restart" do
      it_should_behave_like "Restart strategy"
    end
  end

  describe "TdAgent" do
    let(:described_class) { Fluentd::Agent::TdAgent } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Fluentd::Agent has common behavior"
  end
end

