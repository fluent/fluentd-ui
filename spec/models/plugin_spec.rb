require 'spec_helper'

describe Plugin do
  let(:plugin) { FactoryGirl.build(:plugin) }

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
    before do
      File.unlink Plugin.gemfile
      Plugin.instance_variable_set(:@initial_gemfile_content, nil)
    end

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

    describe "after install succeed" do
      before do
        plugin.stub(:fluent_gem).and_return { true }
        plugin.install!
      end

      it { Plugin.should be_gemfile_changed }
      it { plugin.should be_installed }
    end
  end

  describe "uninstall!" do
    let(:installed_plugin) { FactoryGirl.build(:plugin) }

    before do
      installed_plugin.stub(:fluent_gem).and_return { true }
      File.unlink Plugin.gemfile
      installed_plugin.install!
      Plugin.instance_variable_set(:@initial_gemfile_content, nil)
    end

    before do
      installed_plugin.uninstall!
    end

    it do
      installed_plugin.should_not be_installed
    end

    it do
      Plugin.should be_gemfile_changed
    end

  end
end
