require "test_helper"
require "fluent/plugin/buf_file"

module Fluentd::Setting
  class OutMongoTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::OutMongo
      @valid_attributes = {
        pattern: "mongo.*.*",
        host: "example.com",
        port: 12345,
        database: "mongodb",
        tag_mapped: "true",
      }
      @instance = @klass.new(@valid_attributes)
    end

    sub_test_case "#valid?" do
      test "invalid if database is missing" do
        params = @valid_attributes.dup
        params.delete(:database)
        instance = @klass.new(params)
        assert_false(instance.valid?)
        assert_equal(["connection_string or database parameter is required"], instance.errors.full_messages)
      end

      test "invalid if collection is missing" do
        params = {
          pattern: "mongo.*.*",
          host: "example.com",
          port: 12345,
          database: "mongodb",
        }
        instance = @klass.new(params)
        assert_false(instance.valid?)
        assert_equal(["normal mode requires collection parameter"], instance.errors.full_messages)
      end
    end

    test "#plugin_name" do
      assert_equal("mongo", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("output", @instance.plugin_type)
    end

    test "#to_config" do
      expected = <<-CONFIG.strip_heredoc
        <match mongo.*.*>
          @type mongo
          database mongodb
          host example.com
          port 12345
          tag_mapped true
        </match>
      CONFIG
      assert_equal(expected, @instance.to_config.to_s)
    end
  end
end
