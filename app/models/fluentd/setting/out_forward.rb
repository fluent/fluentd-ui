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
          :pattern, :server, :secondary,
        ]
      end

      def hidden_options
        [
          :inject, :buffer,
          :host, :port
        ]
      end
    end
  end
end
