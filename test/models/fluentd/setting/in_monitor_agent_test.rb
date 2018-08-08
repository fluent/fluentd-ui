require "test_helper"

module Fluentd::Setting
  class InMonitorAgentTest < ActiveSupport::TestCase
    setup do
      @klass = Fluentd::Setting::InMonitorAgent
      @instance = @klass.new({})
    end

    test "#valid?" do
      assert do
        @instance.valid?
      end
    end

    test "#plugin_name" do
      assert_equal("monitor_agent", @instance.plugin_name)
    end

    test "#plugin_type" do
      assert_equal("input", @instance.plugin_type)
    end

    test "#to_config" do
      assert do
        @instance.to_config.to_s.include?("@type monitor_agent")
      end
    end
  end
end
