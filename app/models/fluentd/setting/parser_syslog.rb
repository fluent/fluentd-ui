class Fluentd
  module Setting
    class ParserSyslog
      include Fluentd::Setting::Plugin

      register_plugin("parser", "syslog")

      def self.initial_params
        {}
      end
    end
  end
end
