require 'spec_helper'

describe Plugin do
  let(:plugin) { build(:plugin) }

  before do
    Plugin.stub(:gemfile_path).and_return { Rails.root + "tmp/fluentd-ui-test-gemfile.plugins" }
  end

  after do
    File.unlink Plugin.gemfile_path if File.exist?(Plugin.gemfile_path)
    Plugin.pristine!
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

  describe "#format_gemfile" do
    it { plugin.format_gemfile.should == %Q|gem "#{plugin.gem_name}", "#{plugin.version}"| }
  end

  describe "#install!" do
    describe "invoke fluent_gem" do
      after do
        plugin.stub(:valid?).and_return { valid }
        plugin.stub(:installed?).and_return { installed }
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
      before { plugin.should_receive(:system).and_return { false } }
      subject { expect { plugin.install! } }

      it "raise GemError" do
        subject.to raise_error(Plugin::GemError)
      end

      it "error message contains gem name" do
        subject.to raise_error(/#{plugin.gem_name}/)
      end
    end

    describe "after install succeed" do
      before do
        plugin.stub(:fluent_gem).and_return { true }
        plugin.install!
      end

      it { Plugin.should be_gemfile_changed }
      it { plugin.should be_installed }
    end
  end

  describe "#uninstall!" do
    let(:installed_plugin) { build(:plugin, gem_name: "fluent-plugin-foobar") }

    before do
      installed_plugin.stub(:fluent_gem).and_return { true }
      installed_plugin.install!
      Plugin.pristine!
    end

    before do
      installed_plugin.uninstall!
    end

    it { installed_plugin.should_not be_installed }
    it { Plugin.should be_gemfile_changed }
  end

  describe "#upgrade!" do
    let(:installed_plugin) { build(:plugin, gem_name: "fluent-plugin-foobar", version: current_version) }
    let(:current_version) { "1.0.0" }
    let(:target_version) { "1.2.0" }

    before do
      Plugin.any_instance.stub(:fluent_gem).and_return { true } # NOTE: not `plugin.stub` because upgrade! creates new Plugin instance internally
      installed_plugin.install!
      Plugin.pristine!
      installed_plugin.upgrade!(target_version)
    end

    it { installed_plugin.should be_installed }
    it { Plugin.should be_gemfile_changed }
    it { installed_plugin.installed_version.should == target_version }
  end

  describe ".installed" do
    before do
      plugin.stub(:fluent_gem).and_return { true }
      plugin.install!
    end

    it do
      Plugin.installed.map(&:format_gemfile).should =~ [plugin].map(&:format_gemfile)
    end
  end

  describe "#latest_version?" do
    let(:plugin) { build(:plugin, version: gem_version.to_s) }
    let(:gem_version) { Gem::Version.new("1.0.0") }

    before do
      plugin.stub(:installed_version).and_return { gem_version.to_s }
      stub_request(:get, /rubygems.org/).to_return(body: JSON.dump(api_response))
    end

    subject { plugin.latest_version? }

    context "available updates" do
      let(:api_response) do
        [{number: gem_version.bump}, {number: gem_version}]
      end

      it { subject.should be_false }
    end

    context "unavailable updates" do
      let(:api_response) do
        [{number: gem_version}]
      end

      it { subject.should be_true }
    end
  end

  describe "#installed_version" do
    before do
      Plugin.any_instance.stub(:fluent_gem).and_return { true } # NOTE: not `plugin.stub` because upgrade! creates new Plugin instance internally
      plugin.install!
    end

    it { plugin.installed_version.should == plugin.version }

    context "upgrade to x.y.z" do
      before { plugin.upgrade!(target_version) }
      let(:target_version) { "3.3.3" }

      it { plugin.installed_version.should == target_version }
    end
  end

  describe "#to_param" do
    it { plugin.to_param.should == plugin.gem_name }
  end
end
