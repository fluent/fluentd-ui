require "test_helper"

module Fluentd::Setting
  class InTailTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::InTail
      @params = {
        tag: "dummy.log",
        path: "/tmp/log/dummy.log",
        parse_type: "none",
        parse: {
          "0" => {
            "type" => "none"
          }
        }
      }
      @instance = @klass.new(@params)
    end

    sub_test_case "#valid?" do
      test "valid" do
        assert_true(@instance.valid?)
      end

      test "invalid if tag is missing" do
        params = @params.dup
        params.delete(:tag)
        assert_false(@klass.new(params).valid?)
      end

      test "invalid if path is missing" do
        params = @params.dup
        params.delete(:path)
        assert_false(@klass.new(params).valid?)
      end
    end

    test "#plugin_name" do
      assert_equal("tail", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("input", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type tail")
      end
    end
  end
end
