class Fluentd
  module Setting
    class OutForward
      class Server
        include Common
        KEYS = [
          :name, :host, :port, :weight, :standby
        ].freeze

        attr_accessor(*KEYS)

        flags :standby

        validates :host, presence: true
        validates :port, presence: true
      end

      class Secondary
        include Common
        KEYS = [
          :type, :path
        ].freeze

        attr_accessor(*KEYS)

        hidden :type
        validates :path, presence: true
      end

      include Common

      KEYS = [
        :match,
        :send_timeout, :recover_wait, :heartbeat_type, :heartbeat_interval,
        :phi_threshold, :hard_timeout,
        :server, :secondary
      ].freeze

      attr_accessor(*KEYS)
      choice :heartbeat_type, %w(udp tcp)
      nested :server, Server, multiple: true
      nested :secondary, Secondary

      validates :match, presence: true
      validate :validate_has_at_least_one_server
      validate :validate_nested_values

      def validate_has_at_least_one_server
        if children_of(:server).reject{|s| s.empty_value? }.blank?
          errors.add(:base, :out_forward_blank_server)
        end
      end

      def validate_nested_values
        self.class.children.inject(true) do |result, (key, _)|
          children_of(key).each do |child|
            if !child.empty_value? && !child.valid?
              child.errors.full_messages.each do |message|
                errors.add(:base, "(#{key})#{message}")
              end
              result = false
            end
            result
          end
          result
        end
      end

      def self.initial_params
        {
          secondary: {
            "0" => {
              type: "file",
            }
          }
        }
      end

      def common_options
        [
          :match, :server, :secondary,
        ]
      end

      def advanced_options
        [
          :send_timeout, :recover_wait, :heartbeat_type, :heartbeat_interval,
          :phi_threshold, :hard_timeout,
        ]
      end
    end
  end
end
