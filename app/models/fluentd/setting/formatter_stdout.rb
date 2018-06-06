class Fluentd
  module Setting
    class FormatterStdout
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "stdout")

      def self.initial_params
        {}
      end
    end
  end
end
