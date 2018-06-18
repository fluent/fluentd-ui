class Fluentd
  module Setting
    class FormatterMsgpack
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "msgpack")

      def self.initial_params
        {}
      end
    end
  end
end
