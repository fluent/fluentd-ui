class Fluentd
  module Setting
    module ParserApache
      include Fluentd::Setting::Plugin

      register_plugin("parser", "apache")

      def self.initial_params
        {}
      end
    end
  end
end
