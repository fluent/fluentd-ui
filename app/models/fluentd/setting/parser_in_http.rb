class Fluentd
  module Setting
    class ParserInHttp
      include Fluentd::Setting::Plugin

      register_plugin("parser", "in_http")

      def self.initial_params
        {}
      end
    end
  end
end
