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
          parse_type: "in_http",
          parse: {
            "0" => {
              "type" => "in_http"
            }
          }
        }
      end

      def common_options
        [
          :label, :bind, :port, :add_http_headers, :add_remote_addr
        ]
      end

      def hidden_options
        [
          :parse,
          :backlog,
          :blocking_timeout,
        ]
      end
    end
  end
end
