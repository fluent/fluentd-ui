class Fluentd
  module Setting
    class ParserRegexp
      include Fluentd::Setting::Plugin

      register_plugin("parser", "regexp")

      def self.initial_params
        {}
      end
    end
  end
end
