class Fluentd
  module Setting
    module FormatterCsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "csv")

      def self.initial_params
        {}
      end
    end
  end
end
