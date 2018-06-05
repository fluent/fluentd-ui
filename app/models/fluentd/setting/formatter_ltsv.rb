class Fluentd
  module Setting
    module FormatterLtsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "ltsv")

      def self.initial_params
        {}
      end
    end
  end
end
