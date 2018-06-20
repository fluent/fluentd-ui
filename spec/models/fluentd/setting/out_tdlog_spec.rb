require 'spec_helper'

describe Fluentd::Setting::OutTdlog do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      pattern: "td.*.*",
      apikey: "APIKEY",
      auto_create_table: "true",
    }
  }

  describe "#valid?" do
    it "should be invalid if apikey is missing" do
      params = valid_attributes.dup
      params.delete(:apikey)
      instance = klass.new(params)
      instance.should_not be_valid
      instance.errors.full_messages.should == ["Apikey can't be blank"]
    end
  end

  describe "#plugin_name" do
    subject { instance.plugin_name }
    it { should == "tdlog" }
  end

  describe "#plugin_type" do
    subject { instance.plugin_type }
    it { should == "output" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    let(:expected) {
      <<-CONFIG
<match td.*.*>
  @type tdlog
  apikey APIKEY
</match>
      CONFIG
    }
    it { should == expected }
  end
end
