require 'spec_helper'

describe Fluentd::Setting::OutMongo do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      match: "mongo.*.*",
      host: "example.com",
      port: 12345,
      database: "mongodb",
      tag_mapped: "true",
    }
  }

  describe "#valid?" do
    it "should be invalid if tag parameter lacked" do
      params = valid_attributes.dup
      params.delete(:match)
      klass.new(params).should_not be_valid
    end
  end

  describe "#plugin_type_name" do
    subject { instance.plugin_type_name }
    it { should == "mongo" }
  end

  describe "#input_plugin" do
    it { instance.should_not be_input_plugin }
    it { instance.should be_output_plugin }
  end

  describe "#to_config" do
    subject { instance.to_config }
    it { should include("@type mongo") }
    it { should include("tag_mapped") }
  end
end

