class Fluentd
  module Setting
    class FormatterTsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "tsv")

      def self.initial_params
        {}
      end

      def common_options
        [
          :keys,
          :delimiter,
          :add_newline
        ]
      end
    end
  end
end
