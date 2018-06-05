class Fluentd
  module Setting
    module ParserApache2
      include Fluentd::Setting::Plugin

      register_plugin("parser", "apache2")

      def self.initial_params
        {}
      end
    end
  end
end
