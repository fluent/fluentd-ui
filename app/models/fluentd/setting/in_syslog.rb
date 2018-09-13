class Fluentd
  module Setting
    class InSyslog
      include Fluentd::Setting::Plugin

      register_plugin("input", "syslog")

      def self.initial_params
        params = {
          parse_type: "syslog",
          parse: {
            "0" => {
              "type" => "syslog"
            }
          }
        }
        super.compact.deep_merge(params)
      end

      def common_options
        [
          :label, :tag, :bind, :port
        ]
      end

      def hidden_options
        [
          :parse,
          :transport,
          :blocking_timeout
        ]
      end
    end
  end
end
