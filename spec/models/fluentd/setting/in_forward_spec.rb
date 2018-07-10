require 'spec_helper'

describe Fluentd::Setting::InForward do
  let(:klass) { described_class }
  let(:instance) { klass.new(valid_attributes) }
  let(:valid_attributes) {
    {}
  }

  describe ".initial_params" do
    subject { klass.initial_params }
    let(:expected) do
      {
        log_level: nil,
        port: 24224,
        bind: "0.0.0.0",
        backlog: nil,
        linger_timeout: 0,
        blocking_timeout: 0.5,
        chunk_size_limit: nil,
        chunk_size_warn_limit: nil,
        deny_keepalive: false,
        resolve_hostname: nil,
        skip_invalid_event: false,
        source_address_key: nil,
        source_hostname_key: nil,
        security: {
          "0" => {
            "user_auth" => false,
            "allow_anonymous_source" => true,
            "client" => {
              "0" => {
                "host" => nil,
                "network" => nil,
                "shared_key" => nil,
                "users" => [],
              }
            }
          }
        },
        transport: {
          "0" => {
            "protocol" => :tcp,
            "version" => :TLSv1_2,
            "ciphers" => "ALL:!aNULL:!eNULL:!SSLv2",
            "insecure" => false,
            "ca_path" => nil,
            "cert_path" => nil,
            "private_key_path" => nil,
            "private_key_passphrase" => nil,
            "client_cert_auth" => false,
            "ca_cert_path" => nil,
            "ca_private_key_path" => nil,
            "ca_private_key_passphrase" => nil,
            "generate_private_key_length" => 2048,
            "generate_cert_country" => "US",
            "generate_cert_state" => "CA",
            "generate_cert_locality" => "Mountain View",
            "generate_cert_common_name" => nil,
            "generate_cert_expiration" => 315360000,
            "generate_cert_digest" => :sha256,
          }
        },
      }
    end
    it { should == expected }
  end

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
    it do
      params = {
        security: {
          "0" => {
            self_hostname: "test.fluentd",
          }
        }
      }
      object = klass.new(params)
      object.validate
      object.errors.full_messages.should == ["'shared_key' parameter is required, in section security"]
    end
  end
end
