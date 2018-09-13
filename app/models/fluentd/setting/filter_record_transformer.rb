class Fluentd
  module Setting
    class FilterRecordTransformer
      include Fluentd::Setting::Plugin

      register_plugin("filter", "record_transformer")

      attribute(:record, :string)

      def self.initial_params
        {
        }
      end

      def common_options
        [
          :label,
          :pattern,
        ]
      end

      def hidden_options
        []
      end
    end
  end
end
