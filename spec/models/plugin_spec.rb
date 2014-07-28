require 'spec_helper'

describe Plugin do
  let(:plugin) { build(:plugin) }

  describe ".installed" do
    before { Plugin.stub(:"`").and_return(gem_list) }

    context "fluent-plugin-foo 0.1.2" do
      let(:target) { Plugin.new(gem_name: "fluent-plugin-foo", version: "0.1.2") }
      let(:gem_list) { <<-GEM.strip_heredoc }
        dummy (3.3.3)
        fluent-plugin-foo (0.1.2)
        more_dummy (0.0.1)
      GEM

      it "detect foo plugin" do
        Plugin.installed.first.inspect.should == target.inspect
      end

      it "detected foo plugin is marked as installed" do
        target.should be_installed
      end

      it "detected foo plugin version to be installed_version" do
        target.installed_version.should == target.version
      end
    end
  end

  describe "#valid?" do
    describe "gem_name" do
      subject { plugin }
      before { plugin.gem_name = gem_name }

      context "nil is invalid" do
        let(:gem_name) { nil }
        it { should_not be_valid }
      end

      context "somthing filled is valid" do
        let(:gem_name) { "foobar" }
        it { should be_valid }
      end
    end

    describe "version" do
      subject { plugin }
      before { plugin.version = version }

      context "nil is invalid" do
        let(:version) { nil }
        it { should_not be_valid }
      end

      context "somthing filled is valid" do
        let(:version) { "0.0.1" }
        it { should be_valid }
      end
    end
  end

  describe "#install!" do
    describe "invoke fluent_gem" do
      after do
        plugin.stub(:valid?).and_return(valid)
        plugin.stub(:installed?).and_return(installed)
        plugin.install!
      end

      context "valid" do
        let(:valid) { true }

        context "installed" do
          let(:installed) { true }
          it { plugin.should_not_receive(:fluent_gem) }
        end

        context "not installed" do
          let(:installed) { false }
          it { plugin.should_receive(:fluent_gem) }
        end
      end

      context "invalid" do
        let(:valid) { false }

        context "installed" do
          let(:installed) { true }
          it { plugin.should_not_receive(:fluent_gem) }
        end

        context "not installed" do
          let(:installed) { false }
          it { plugin.should_not_receive(:fluent_gem) }
        end
      end
    end

    context "system command error" do
      before { plugin.should_receive(:system).at_least(1).and_return(false) }
      subject { expect { plugin.install! } }

      it "raise GemError" do
        subject.to raise_error(Plugin::GemError)
      end

      it "error message contains gem name" do
        subject.to raise_error(/#{plugin.gem_name}/)
      end
    end
  end

  describe "#uninstall!" do
    let(:installed_plugin) { build(:plugin, gem_name: "fluent-plugin-foobar") }

    before do
      installed_plugin.stub(:installed?).and_return(installed)
    end

    context "installed" do
      let(:installed) { true } 
      before { installed_plugin.should_receive(:gem_uninstall) }
      it { installed_plugin.uninstall! }
    end

    context "not installed" do
      let(:installed) { false } 
      before { installed_plugin.should_not_receive(:gem_uninstall) }
      it { installed_plugin.uninstall! }
    end
  end

  describe "#upgrade!" do
    let(:installed_plugin) { build(:plugin, gem_name: "fluent-plugin-foobar", version: current_version) }
    let(:current_version) { "1.0.0" }
    let(:target_version) { "1.2.0" }

    before do
      # NOTE: not `plugin.stub` because upgrade! creates new Plugin instance internally
      installed_plugin.stub(:installed?).and_return(true)
      Plugin.any_instance.stub(:fluent_gem).and_return(true)

      installed_plugin.should_receive(:uninstall!)
      Plugin.any_instance.should_receive(:install!)
    end

    it { installed_plugin.upgrade!(target_version) }
  end

  describe "#to_param" do
    it { plugin.to_param.should == plugin.gem_name }
  end
end
