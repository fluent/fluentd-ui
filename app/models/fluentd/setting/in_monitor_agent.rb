class Fluentd
  module Setting
    class InMonitorAgent
      include Fluentd::Setting::Plugin

      register_plugin("input", "monitor_agent")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 24220,
          emit_interval: 60,
          include_config: true,
          include_retry: true
        }
      end

      def common_options
        [
          :bind, :port, :tag
        ]
      end
    end
  end
end
