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
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      def hidden_options
        [
          # We don't support TLS configuration via fluentd-ui for now.
          :transport
        ]
      end
    end
  end
end
