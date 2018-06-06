class Fluentd
  module Setting
    class FormatterHash
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "hash")

      def self.initial_params
        {}
      end
    end
  end
end
