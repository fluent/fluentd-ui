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

    describe "#logged_errors" do
      before { instance.stub(:log_file).and_return(logfile) }

      describe "#errors_since" do
        let(:logged_time) { Time.parse('2014-05-27') }
        let(:now) { Time.parse('2014-05-29') }

        before { Timecop.freeze(now) }
        after { Timecop.return }

        subject { instance.errors_since(days.days.ago) }

        context "has no errors" do
          let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }
          let(:days) { 100 }

          it "empty array" do
            should be_empty
          end
        end

        context "has errors" do
          let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }

          context "unreachable since" do
            let(:days) { 0 }
            it { should be_empty }
          end

          context "reachable since" do
            let(:days) { 100 }

            it "contain stack trace" do
              subject[0][:subject].should include("Address already in use - bind(2)")
            end

            it "newer(bottom) is first" do
              one = Time.parse(subject[0][:subject])
              two = Time.parse(subject[1][:subject])
              one.should >= two
            end
          end
        end
      end

      describe "#recent_errors" do
        context "have 0 error log" do
          let(:logfile) { File.expand_path("./spec/support/fixtures/error0.log", Rails.root) }
          subject { instance.recent_errors(2) }

          it "empty array" do
            should be_empty
          end
        end

        context "have 2 error log" do
          let(:logfile) { File.expand_path("./spec/support/fixtures/error2.log", Rails.root) }
          subject { instance.recent_errors(2) }

          describe "limit" do
            subject { instance.recent_errors(limit).length }

            context "=1" do
              let(:limit) { 1 }
              it { should == limit }
            end

            context "=2" do
              let(:limit) { 2 }
              it { should == limit }
            end
          end

          it "contain stack trace" do
            subject[0][:subject].should include("Address already in use - bind(2)")
          end

          it "newer(bottom) is first" do
            one = Time.parse(subject[0][:subject])
            two = Time.parse(subject[1][:subject])
            one.should >= two
          end
        end
      end
    end
  end

  let(:instance) { described_class.new(options) }
  let(:options) { {} }

  describe "FluentdGem" do
    let(:described_class) { Fluentd::Agent::FluentdGem } # override nested described_class behavior as https://github.com/rspec/rspec-core/issues/1114

    it_should_behave_like "Agent has common behavior"

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
      before { instance.stub(:stop).and_return(stop_result) }
      before { instance.stub(:start).and_return(start_result) }
      subject { instance.restart }

      describe "return true only if #stop and #start success" do
        context "#stop success" do
          let(:stop_result) { true } 

          context" #start success" do
            let(:start_result) { true } 
            it { should be_truthy }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_falsy }
          end
        end

        context "#stop fail" do
          let(:stop_result) { false } 

          context" #start success" do
            let(:start_result) { true } 
            it { should be_falsy }
          end

          context" #start fail" do
            let(:start_result) { false } 
            it { should be_falsy }
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

