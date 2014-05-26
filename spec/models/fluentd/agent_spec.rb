require 'spec_helper'

describe Fluentd::Agent do
  shared_examples_for "Agent has common behavior" do |klass|
    describe "#extra_options" do
      context "blank" do
        let(:options) { {} }
        it { instance.pid_file.should    == described_class.default_options[:pid_file] }
        it { instance.log_file.should    == described_class.default_options[:log_file] }
        it { instance.config_file.should == described_class.default_options[:config_file] }
      end

      context "given" do
        let(:options) do
          {
            :pid_file => pid_file,
            :log_file => log_file,
            :config_file => config_file,
          }
        end
        let(:pid_file) { "pid" }
        let(:log_file) { "log" }
        let(:config_file) { "config" }

        it { instance.pid_file.should == pid_file }
        it { instance.log_file.should == log_file }
        it { instance.config_file.should == config_file }
      end
    end
  end

  let(:instance) { described_class.new(options) }
  let(:options) { {} }

  describe "Fluentd" do
    let(:described_class) { Fluentd::Agent::Fluentd } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Agent has common behavior"

    describe "#options_to_argv" do
      subject { instance.options_to_argv }
      it { should include("-c #{instance.config_file}") }
      it { should include("-d #{instance.pid_file}") }
      it { should include("-o #{instance.log_file}") }
      it { should include("--use-v1-config") }
    end

    describe "#start" do
      before { instance.stub(:running?).and_return { running } }

      context "running" do
        let(:running) { true }

        subject { instance.start }

        it { should be_true }
      end

      context "not running" do
        let(:running) { false }

        subject { instance.start }

        before do
          instance.stub(:actual_start).and_return { start_result }
        end

        context "actual start success" do
          let(:start_result) { true }
          it { should be_true }
        end

        context "actual start failed" do
          let(:start_result) { false }
          it { should be_false }
        end
      end
    end

    describe "#stop" do
      before { instance.stub(:running?).and_return { running } }

      subject { instance.stop }

      context "running" do
        let(:running) { true }

        before { instance.stub(:actual_stop).and_return { stop_result } }

        context "actual stop success" do
          let(:stop_result) { true }
          it { should be_true }
        end

        context "actual stop failed" do
          let(:stop_result) { false }
          it { should be_false }
        end
      end

      context "not running" do
        let(:running) { false }

        it { should be_true }
      end
    end

    describe "#restart" do
      before { instance.stub(:stop).and_return { stop_result } }
      before { instance.stub(:start).and_return { start_result } }
      subject { instance.restart }

      describe "return true only if #stop and #start success" do
        context "#stop success" do
          let(:stop_result) { true } 

          context" #start success" do
            let(:start_result) { true } 
            it { should be_true }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_false }
          end
        end

        context "#stop fail" do
          let(:stop_result) { false } 

          context" #start success" do
            let(:start_result) { true } 
            it { should be_false }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_false }
          end
        end
      end
    end
  end

  describe "TdAgent" do
    let(:described_class) { Fluentd::Agent::TdAgent } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Agent has common behavior"
  end
end

