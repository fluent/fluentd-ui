class Fluentd
  module Setting
    class InMonitorAgent
      include Fluentd::Setting::Plugin

      register_plugin("input", "monitor_agent")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 24220,
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      def advanced_options
        []
      end
    end
  end
end
