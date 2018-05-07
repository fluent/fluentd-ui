class Fluentd
  module Setting
    class InSyslog
      include Fluentd::Setting::Plugin

      register_plugin("input", "syslog")

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 5140,
          parse: {
            "0" => {
              type: :syslog
            }
          },
          protocol_type: :udp,
        }
      end

      def common_options
        [
          :tag, :bind, :port,
        ]
      end

      def advanced_options
        [
          :parse, :protocol_type, :source_hostname_key, :resolve_hostname,
          :source_address_key, :priority_key, :facility_key, :message_length_limit
        ]
      end
    end
  end
end
