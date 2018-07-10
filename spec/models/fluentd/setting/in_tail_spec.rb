require 'spec_helper'

describe Fluentd::Setting::InTail do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      tag: "dummy.log",
      path: "/tmp/log/dummy.log",
      parse_type: "none",
      parse: {
        "0" => {
          "type" => "none"
        }
      }
    }
  }

  describe "#valid?" do
    it "should be valid" do
      params = valid_attributes.dup
      klass.new(params).should be_valid
    end

    it "should be invalid if tag parameter is missing" do
      params = valid_attributes.dup
      params.delete(:tag)
      klass.new(params).should_not be_valid
    end

    it "should be invalid if path parameter is missing" do
      params = valid_attributes.dup
      params.delete(:path)
      klass.new(params).should_not be_valid
    end
  end


  describe "#plugin_name" do
    subject { instance.plugin_name }
    it { should == "tail" }
  end

  describe "#plugin_type" do
    subject { instance.plugin_type }
    it { should == "input" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    it { should include("@type tail") }
  end
end
