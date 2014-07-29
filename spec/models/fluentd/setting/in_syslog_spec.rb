require 'spec_helper'

describe Fluentd::Setting::InSyslog do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      tag: "foo.bar",
    }
  }

  describe "#valid?" do
    it "should be invalid if tag parameter lacked" do
      params = valid_attributes.dup
      params.delete(:tag)
      klass.new(params).should_not be_valid
    end
  end

  describe "#plugin_type_name" do
    subject { instance.plugin_type_name }
    it { should == "syslog" }
  end

  describe "#input_plugin" do
    it { instance.should be_input_plugin }
    it { instance.should_not be_output_plugin }
  end

  describe "#to_config" do
    subject { instance.to_config }
    it { should include("type syslog") }
  end
end

