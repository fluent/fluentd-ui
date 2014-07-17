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
      end

      class Secondary
        include Common
        KEYS = [
          :path, :type
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
      nested :server, Server
      nested :secondary, Secondary

      validates :match, presence: true
      validate :validate_at_least_one_server
      validate :validate_nested_values

      def validate_at_least_one_server
        # FIXME: real validation
        true
      end

      def validate_nested_values
        # FIXME: real validation with child class instance
        self.class.children.inject(true) do |result, child|
          # result & child.valid?
        end
        true
      end
    end
  end
end
