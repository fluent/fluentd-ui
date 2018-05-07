class Fluentd
  module Setting
    class InHttp
      include Fluentd::Setting::Plugin

      register_plugin("input", "http")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 8888,
          body_size_limit: "32m",
          keepalive_timeout: "10s",
          add_http_headers: false,
          format: "default",
          log_level: "info",
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      def advanced_options
        [
          :body_size_limit, :keepalive_timeout, :add_http_headers, :format, :log_level
        ]
      end
    end
  end
end
