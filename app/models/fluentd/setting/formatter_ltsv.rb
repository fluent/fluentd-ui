class Fluentd
  module Setting
    class FormatterLtsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "ltsv")

      def self.initial_params
        {}
      end
    end
  end
end
