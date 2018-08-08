require "test_helper"

require "fluent/plugin/buf_file"

module Fluentd::Setting
  class OutElasticsearchTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::OutElasticsearch
      @instance = @klass.new({})
    end

    test "#valid?" do
      assert do
        @instance.valid?
      end
    end

    test "#plugin_name" do
      assert_equal("elasticsearch", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("output", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type elasticsearch")
      end
    end
  end
end
