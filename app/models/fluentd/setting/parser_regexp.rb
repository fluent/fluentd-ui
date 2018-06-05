class Fluentd
  module Setting
    module ParserRegexp
      include Fluentd::Setting::Plugin

      register_plugin("parser", "regexp")

      def self.initial_params
        {}
      end
    end
  end
end
