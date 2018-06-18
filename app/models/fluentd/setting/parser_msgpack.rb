class Fluentd
  module Setting
    class ParserMsgpack
      include Fluentd::Setting::Plugin

      register_plugin("parser", "msgpack")

      def self.initial_params
        {}
      end
    end
  end
end
