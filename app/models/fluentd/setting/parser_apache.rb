class Fluentd
  module Setting
    class ParserApache
      include Fluentd::Setting::Plugin

      register_plugin("parser", "apache")

      def self.initial_params
        {}
      end
    end
  end
end
