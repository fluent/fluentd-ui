require 'spec_helper'

describe Fluentd::Setting::InHttp do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {}
  }

  describe "#valid?" do
    it "should be valid" do
      params = valid_attributes.dup
      klass.new(params).should be_valid
    end
  end

  describe "#plugin_name" do
    subject { instance.plugin_name }
    it { should == "http" }
  end

  describe "#plugin_type" do
    subject { instance.plugin_type }
    it { should == "input" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    it { should include("@type http") }
  end
end
