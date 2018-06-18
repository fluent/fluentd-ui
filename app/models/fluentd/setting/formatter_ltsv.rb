class Fluentd
  module Setting
    class FormatterLtsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "ltsv")

      def self.initial_params
        {}
      end

      def common_options
        [
          :delimiter,
          :label_delimiter,
          :add_newline
        ]
      end
    end
  end
end
