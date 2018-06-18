class Fluentd
  module Setting
    class ParserRegexp
      include Fluentd::Setting::Plugin

      register_plugin("parser", "regexp")

      def self.initial_params
        {}
      end

      def common_options
        [
          :expression
        ]
      end

      def hidden_options
        [
          :ignorecase,
          :multiline
        ]
      end
    end
  end
end
