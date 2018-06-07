class Fluentd
  module Setting
    class ParserJson
      include Fluentd::Setting::Plugin

      register_plugin("parser", "json")

      def self.initial_params
        {
          json_parser: "oj"
        }
      end

      def common_options
        []
      end

      def advanced_options
        [
          :json_parser
        ]
      end
    end
  end
end
