require "test_helper"

module Fluentd::Setting
  class InHttpTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::InHttp
      @instance = @klass.new({})
    end

    test "#valid?" do
      assert do
        @instance.valid?
      end
    end

    test "#plugin_name" do
      assert_equal("http", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("input", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type http")
      end
    end
  end
end
