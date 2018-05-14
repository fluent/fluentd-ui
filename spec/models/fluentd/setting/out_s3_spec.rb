require 'spec_helper'

describe Fluentd::Setting::OutS3 do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {
      s3_bucket: "bucketname"
    }
  }

  describe "#valid?" do
    it "should be valid" do
      params = valid_attributes.dup
      instance = klass.new(params)
      instance.should be_valid
    end
  end

  describe "#invalid?" do
    it "should be invalid if s3_bucket parameter is missing" do
      params = valid_attributes.dup
      params.delete(:s3_bucket)
      instance = klass.new(params)
      instance.should be_invalid
    end
  end

  describe "#plugin_name" do
    subject { instance.plugin_name }
    it { should == "s3" }
  end

  describe "#plugin_type" do
    subject { instance.plugin_type }
    it { should == "output" }
  end

  describe "#to_config" do
    subject { instance.to_config.to_s }
    it { should include("@type s3") }
  end

  describe "with assume_role_credentials" do
    let(:valid_attributes) {
      {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        assume_role_credentials: {
          "0" => {
            role_arn: "arn",
            role_session_name: "session_name",
          }
        }
      }
    }
    let(:expected) {
      <<-CONFIG
<match s3.*>
  @type s3
  s3_bucket bucketname
  <assume_role_credentials>
    role_arn arn
    role_session_name session_name
  </assume_role_credentials>
</match>
      CONFIG
    }
    subject { instance.to_config.to_s }
    it { should == expected }
  end

  describe "with instance_profile_credentials" do
    let(:valid_attributes) {
      {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        instance_profile_credentials: {
          "0" => {
            port: 80
          }
        }
      }
    }
    let(:expected) {
      <<-CONFIG
<match s3.*>
  @type s3
  s3_bucket bucketname
  <instance_profile_credentials>
    port 80
  </instance_profile_credentials>
</match>
      CONFIG
    }
    subject { instance.to_config.to_s }
    it { should == expected }
  end

  describe "with shared_credentials" do
    let(:valid_attributes) {
      {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        shared_credentials: {
          "0" => {
            path: "$HOME/.aws/credentials",
            profile_name: "default",
          }
        }
      }
    }
    let(:expected) {
      <<-CONFIG
<match s3.*>
  @type s3
  s3_bucket bucketname
  <shared_credentials>
    path $HOME/.aws/credentials
    profile_name default
  </shared_credentials>
</match>
      CONFIG
    }
    subject { instance.to_config.to_s }
    it { should == expected }
  end
end
