class Fluentd
  module Setting
    class FilterRecordTransformer
      include Fluentd::Setting::Plugin

      register_plugin("filter", "record_transformer")

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
