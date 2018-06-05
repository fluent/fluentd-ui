class Fluentd
  module Setting
    module ParserJson
      include Fluentd::Setting::Plugin

      register_plugin("parser", "json")

      def self.initial_params
        {
          json_parser: "oj"
        }
      end
    end
  end
end
