class Fluentd
  module Setting
    class InSyslog
      include Fluentd::Setting::Plugin

      register_plugin("input", "syslog")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 5140,
          parse_type: "syslog",
          parse: {
            "0" => {
              "type" => "syslog"
            }
          },
          protocol_type: :udp,
        }
      end

      def common_options
        [
          :tag, :bind, :port
        ]
      end

      def hidden_options
        [
          :parse
        ]
      end
    end
  end
end
