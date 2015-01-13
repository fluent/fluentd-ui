require 'spec_helper'

describe Fluentd::Setting::OutS3 do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }

  skip "TODO: need Fluentd::Setting::OutS3 changing"

  context "0.4.x" do
    let(:valid_attributes) {
      {
        match: "s3.*.*",
        s3_endpoint: "s3-us-west-1.amazonaws.com",
      }
    }
    before { described_class.stub(:installed_version).and_return("0.4.0") }

    describe "#valid?" do
      it "empty values" do
        klass.new({}).should_not be_valid
      end

      it "valid values" do
        klass.new(valid_attributes).should be_valid
      end
    end
  end

  context "0.5.x" do
    let(:valid_attributes) {
      {
        match: "s3.*.*",
        s3_region: "us-west-1",
      }
    }
    before { described_class.stub(:installed_version).and_return("0.5.0") }

    describe "#valid?" do
      it "empty values" do
        klass.new({}).should_not be_valid
      end

      it "valid values" do
        klass.new(valid_attributes).should be_valid
      end
    end
  end

  describe "#plugin_type_name" do
    subject { instance.plugin_type_name }
    it { should == "s3" }
  end

  describe "#input_plugin" do
    it { instance.should_not be_input_plugin }
    it { instance.should be_output_plugin }
  end

  describe "#to_config" do
    subject { instance.to_config }
    it { should include("type s3") }
  end
end

