class Fluentd
  module Setting
    module FormatterSingleValue
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "single_value")

      def self.initial_params
        {}
      end
    end
  end
end
