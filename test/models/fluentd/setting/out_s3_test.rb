require "test_helper"
require "fluent/plugin/buf_file"

module Fluentd::Setting
  class OutS3Test < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::OutS3
      @valid_attributes = {
        s3_bucket: "bucketname"
      }
      @instance = @klass.new(@valid_attributes)
    end

    sub_test_case "#valid?" do
      test "valid" do
        assert_true(@instance.valid?)
      end

      test "invalid if s3_bucket is missing" do
        instance = @klass.new({})
        assert_false(instance.valid?)
      end
    end

    test "#plugin_name" do
      assert_equal("s3", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("output", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type s3")
      end
    end

    test "with assume_role_credentials" do
      params = {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        assume_role_credentials: {
          "0" => {
            role_arn: "arn",
            role_session_name: "session_name",
          }
        }
      }
      expected = <<-CONFIG.strip_heredoc
        <match s3.*>
          @type s3
          s3_bucket bucketname
          <assume_role_credentials>
            role_arn arn
            role_session_name session_name
          </assume_role_credentials>
        </match>
      CONFIG
      instance = @klass.new(params)
      assert_equal(expected, instance.to_config.to_s)
    end

    test "with instance_profile_credentials" do
      params = {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        instance_profile_credentials: {
          "0" => {
            port: 80
          }
        }
      }
      expected = <<-CONFIG.strip_heredoc
        <match s3.*>
          @type s3
          s3_bucket bucketname
          <instance_profile_credentials>
            port 80
          </instance_profile_credentials>
        </match>
      CONFIG
      instance = @klass.new(params)
      assert_equal(expected, instance.to_config.to_s)
    end

    test "with shared_credentials" do
      params = {
        pattern: "s3.*",
        s3_bucket: "bucketname",
        shared_credentials: {
          "0" => {
            path: "$HOME/.aws/credentials",
            profile_name: "default",
          }
        }
      }
      expected = <<-CONFIG.strip_heredoc
        <match s3.*>
          @type s3
          s3_bucket bucketname
          <shared_credentials>
            path $HOME/.aws/credentials
            profile_name default
          </shared_credentials>
        </match>
      CONFIG
      instance = @klass.new(params)
      assert_equal(expected, instance.to_config.to_s)
    end
  end
end
