class Fluentd
  module Setting
    class FormatterSingleValue
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "single_value")

      def self.initial_params
        {}
      end
    end
  end
end
