class Fluentd
  module Setting
    class FilterParser
      include Fluentd::Setting::Plugin

      register_plugin("filter", "parser")

      def self.initial_params
        {
          parse_type: "none",
          parse: {
            "0" => {
              "type" => "none"
            }
          }
        }
      end

      def common_options
        [
          :label,
          :pattern,
          :key_name,
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
