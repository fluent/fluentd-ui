class Fluentd
  module Setting
    module ParserMultiline
      include Fluentd::Setting::Plugin

      register_plugin("parser", "multiline")

      def self.initial_params
        {}
      end
    end
  end
end
