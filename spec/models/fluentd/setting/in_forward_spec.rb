require 'spec_helper'

describe Fluentd::Setting::InForward do
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
    it { should == "forward" }
  end

  describe "#plugin_type" do
    subject { instance.plugin_type }
    it { should == "input" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    it { should include("@type forward") }
  end

  describe "with security section" do
    let(:valid_attributes) {
      {
        security: {
          "0" => {
            self_hostname: "test.fluentd",
            shared_key: "secretsharedkey",
          }
        }
      }
    }
    let(:expected) {
      <<-CONFIG
<source>
  @type forward
  <security>
    self_hostname test.fluentd
    shared_key secretsharedkey
  </security>
</source>
      CONFIG
    }
    subject { instance.to_config.to_s }
    it { should == expected }
  end

  describe "with invalid security section" do
    let(:valid_attributes) {
      {
        security: {
          "0" => {
            self_hostname: "test.fluentd",
          }
        }
      }
    }
    it { instance.should_not be_valid }
    it {
      instance.validate
      instance.errors.full_messages.should include("Security Shared key can't be blank")
    }
  end
end

