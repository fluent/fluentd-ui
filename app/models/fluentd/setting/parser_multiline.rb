class Fluentd
  module Setting
    class ParserMultiline
      include Fluentd::Setting::Plugin

      register_plugin("parser", "multiline")

      def self.initial_params
        {}
      end
    end
  end
end
