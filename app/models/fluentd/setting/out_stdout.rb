class Fluentd
  module Setting
    class OutStdout
      include Common

      KEYS = [:match, :output_type].freeze

      attr_accessor(*KEYS)

      choice :output_type, %w(json hash)

      validates :match, presence: true
      validates :output_type, inclusion: { in: %w(json hash) }

      def self.initial_params
        {
          match: "debug.**",
          output_type: "json",
        }
      end

      def common_options
        [
          :match, :output_type
        ]
      end

      def advanced_options
        []
      end

      def plugin_name
        "stdout"
      end
    end
  end
end
