class Fluentd
  module Setting
    class FormatterCsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "csv")

      def self.initial_params
        {}
      end
    end
  end
end
