require 'spec_helper'

describe Fluentd::Setting::OutMongo do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      pattern: "mongo.*.*",
      host: "example.com",
      port: 12345,
      database: "mongodb",
      tag_mapped: "true",
    }
  }

  describe "#valid?" do
    it "should be invalid if database parameter is missing" do
      params = valid_attributes.dup
      params.delete(:database)
      instance = klass.new(params)
      instance.should_not be_valid
      instance.errors.full_messages.should == ["Database can't be blank"]
    end

    it "should be invalid if collection is missing" do
      params = {
        pattern: "mongo.*.*",
        host: "example.com",
        port: 12345,
        database: "mongodb",
      }
      instance = klass.new(params)
      instance.should_not be_valid
      instance.errors.full_messages.should == ["Collection can't be blank"]
    end
  end

  describe "#plugin_name" do
    subject { instance.plugin_name }
    it { should == "mongo" }
  end

  describe "#plugin_type" do
    it { instance.plugin_type.should == "output" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    let(:expected) {
      <<-CONFIG
<match mongo.*.*>
  @type mongo
  database mongodb
  host example.com
  port 12345
  tag_mapped true
</match>
      CONFIG
    }
    it { should == expected}
  end
end

