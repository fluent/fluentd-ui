require "test_helper"

module Fluentd::Setting
  class InForwardTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::InForward
    end

    test ".initial_params" do
      expected = {
        add_tag_prefix: nil,
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
        send_keepalive_packet: false,
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
        tag: nil,
        transport: {
          "0" => {
            "protocol" => :tcp,
            "version" => :TLSv1_2,
            "ciphers" => "ALL:!aNULL:!eNULL:!SSLv2",
            "insecure" => false,
            "ca_path" => nil,
            "cert_path" => nil,
            "cert_verifier" => nil,
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
            "max_version" => nil,
            "min_version" => nil,
          }
        },
      }
      assert_equal(expected, @klass.initial_params)
    end

    test "#valid?" do
      assert do
        @klass.new({}).valid?
      end
    end

    test "#plugin_name" do
      assert_equal("forward", @klass.new({}).plugin_name)
    end

    test "#plugin_type" do
      assert_equal("input", @klass.new({}).plugin_type)
    end

    test "#to_config" do
      assert do
        @klass.new({}).to_config.to_s.include?("@type forward")
      end
    end

    test "with security section" do
      valid_attributes = {
        security: {
          "0" => {
            self_hostname: "test.fluentd",
            shared_key: "secretsharedkey",
          }
        }
      }
      expected = <<-CONFIG
<source>
  @type forward
  <security>
    self_hostname test.fluentd
    shared_key secretsharedkey
  </security>
</source>
      CONFIG
      assert_equal(expected, @klass.new(valid_attributes).to_config.to_s)
    end

    test "with invalid security section" do
      params = {
        security: {
          "0" => {
            self_hostname: "test.fluentd",
          }
        }
      }
      object = @klass.new(params)
      object.validate
      assert_equal(["'shared_key' parameter is required, in section security"], object.errors.full_messages)
    end
  end
end
