require "test_helper"
require "fluent/plugin/buf_file"

module Fluentd::Setting
  class OutTdlogTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::OutTdlog
      @valid_attributes = {
        pattern: "td.*.*",
        apikey: "APIKEY",
        auto_create_table: "true",
        buffer: {
          "0" => {
            type: "file",
            path: "/tmp/buffer"
          }
        }
      }
      @instance = @klass.new(@valid_attributes)
    end

    sub_test_case "#valid?" do
      test "valid" do
        assert do
          @instance.valid?
        end
      end

      test "invalid if apikey is missing" do
        params = @valid_attributes.dup
        params.delete(:apikey)
        instance = @klass.new(params)
        assert_false(instance.valid?)
        assert_equal(["'apikey' parameter is required"], instance.errors.full_messages)
      end
    end

    test "#plugin_name" do
      assert_equal("tdlog", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("output", @instance.plugin_type)
    end

    test "#to_config" do
      expected = <<-CONFIG.strip_heredoc
        <match td.*.*>
          @type tdlog
          apikey APIKEY
          <buffer>
            @type file
            path /tmp/buffer
          </buffer>
        </match>
      CONFIG
      assert_equal(expected, @instance.to_config.to_s)
    end
  end
end
