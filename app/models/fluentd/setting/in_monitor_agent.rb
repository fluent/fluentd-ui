class Fluentd
  module Setting
    class InMonitorAgent
      include ActiveModel::Model
      include Common

      KEYS = [
        :bind, :port
      ].freeze

      attr_accessor(*KEYS)

      validates :bind, presence: true
      validates :port, presence: true

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 24220,
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      def advanced_options
        []
      end

      def plugin_name
        "monitor_agent"
      end
    end
  end
end
