class Fluentd
  module Setting
    class FormatterCsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "csv")

      def self.initial_params
        {}
      end

      def common_options
        [
          :delimiter,
          :fields,
          :add_newline
        ]
      end
    end
  end
end
