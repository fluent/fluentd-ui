class Fluentd
  module Setting
    class FormatterHash
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "hash")

      def self.initial_params
        {}
      end

      def common_options
        [
          :add_newline
        ]
      end
    end
  end
end
