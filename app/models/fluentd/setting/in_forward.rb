class Fluentd
  module Setting
    class InForward
      include Fluentd::Setting::Plugin

      register_plugin("input", "forward")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 24224,
          linger_timeout: 0,
          chunk_size_limit: nil,
          chunk_size_warn_limit: nil,
          log_level: "info",
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      # TODO Support <transport>, <security>
      def advanced_options
        [
          :linger_timeout, :chunk_size_limit, :chunk_size_warn_limit, :log_level
        ]
      end
    end
  end
end
