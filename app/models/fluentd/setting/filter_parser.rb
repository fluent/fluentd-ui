class Fluentd
  module Setting
    class FilterParser
      include Fluentd::Setting::Plugin

      register_plugin("filter", "parser")

      def self.initial_params
        {
        }
      end

      def common_options
        [
          :pattern,
        ]
      end

      def hidden_options
        []
      end
    end
  end
end
