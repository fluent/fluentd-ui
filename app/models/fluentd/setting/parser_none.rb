class Fluentd
  module Setting
    class ParserNone
      include Fluentd::Setting::Plugin

      register_plugin("parser", "none")

      def self.initial_params
        {}
      end
    end
  end
end
