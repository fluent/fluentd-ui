class Fluentd
  module Setting
    class ParserNone
      include Fluentd::Setting::Plugin

      register_plugin("parser", "none")

      def self.initial_params
        {}
      end

      def common_options
        [
          :message_key
        ]
      end
    end
  end
end
