class Fluentd
  module Setting
    class FormatterJson
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "json")

      def self.initial_params
        {}
      end

      def common_options
        [
          :add_newline
        ]
      end

      def advanced_options
        [
          :json_parser
        ]
      end
    end
  end
end
