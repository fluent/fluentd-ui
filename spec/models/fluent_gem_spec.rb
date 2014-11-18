require 'spec_helper'

describe FluentGem do
  describe "invoker" do
    describe "#install" do
      let(:gem) { FluentGem.gem }

      context "no argument" do
        after { FluentGem.install }
        it { FluentGem.should_receive(:run).with("install") }
      end

      context "with arguments" do
        after { FluentGem.install(*args) }

        context "1" do
          let(:args) { ["plugin-foo"] }
          it { FluentGem.should_receive(:run).with("install", *args) }
        end

        context "2" do
          let(:args) { ["plugin-foo", "--no-document"] }
          it { FluentGem.should_receive(:run).with("install", *args) }
        end
      end
    end

    describe "#uninstall" do
      let(:gem) { FluentGem.gem }

      context "no argument" do
        after { FluentGem.uninstall }
        it { FluentGem.should_receive(:run).with("uninstall") }
      end

      context "with arguments" do
        after { FluentGem.uninstall(*args) }

        context "1" do
          let(:args) { ["plugin-foo"] }
          it { FluentGem.should_receive(:run).with("uninstall", *args) }
        end

        context "2" do
          let(:args) { ["plugin-foo", "--no-document"] }
          it { FluentGem.should_receive(:run).with("uninstall", *args) }
        end
      end
    end
  end

  describe "#list" do
    before { FluentGem.stub(:`).and_return(gem_list) }
    subject { FluentGem.list }

    context "no list" do
      let(:gem_list) { "" }
      it { subject.should == [] }
    end

    context "some lines" do
      let(:gem_list) { <<-GEM.strip_heredoc }
        dummy (3.3.3)
        fluent-plugin-foo (0.1.2)
        more_dummy (0.0.1)
      GEM
      it { subject.should == gem_list.lines }
    end

    context "failed" do
      let(:gem_list) { "" }
      before { $?.stub(:exitstatus).and_return(128) }
      it { expect{ subject }.to raise_error(FluentGem::GemError) }
    end
  end

  describe "#run" do
    before { FluentGem.stub(:system).and_return(ret) }
    let(:args) { ["install", "foobar"] }

    describe "success" do
      let(:ret) { true }
      after { FluentGem.run(*args) }
      it { FluentGem.should_receive(:system) }
    end

    describe "failed" do
      let(:ret) { false }
      it { expect{ FluentGem.run(*args) }.to raise_error(FluentGem::GemError) }
    end
  end

  describe "#gem" do
    before { Fluentd.stub(:instance).and_return(instance) }
    subject { FluentGem.gem }

    context "any instance not setup yet" do
      let(:instance) { nil }
      it { should == "fluent-gem" }
    end

    context "fluentd setup" do
      let(:instance) { Fluentd.new(id: nil, variant: "fluentd_gem", log_file: "dummy.log", pid_file: "dummy.pid", config_file: "dummy.conf") }
      it { should == "fluent-gem" }
    end

    context "td-agent 2 setup" do
      let(:instance) { Fluentd.new(id: nil, variant: "td_agent", log_file: "dummy.log", pid_file: "dummy.pid", config_file: "dummy.conf") }
      it { should == FluentGem.detect_td_agent_gem }
    end
  end
end
