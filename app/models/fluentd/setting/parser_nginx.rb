class Fluentd
  module Setting
    class ParserNginx
      include Fluentd::Setting::Plugin

      register_plugin("parser", "nginx")

      def self.initial_params
        {}
      end
    end
  end
end
