class Fluentd
  module Setting
    class OutForward
      include Fluentd::Setting::Plugin

      register_plugin("output", "forward")

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
