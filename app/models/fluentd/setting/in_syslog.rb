class Fluentd
  module Setting
    class InSyslog
      include ActiveModel::Model
      include Common

      KEYS = [
        :port, :bind, :tag, :types
      ].freeze

      attr_accessor(*KEYS)

      validates :tag, presence: true

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 5140,
        }
      end

      def common_options
        [
          :tag, :bind, :port, :types,
        ]
      end

      def advanced_options
        []
      end
    end
  end
end
