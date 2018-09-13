class Fluentd
  module Setting
    class OutStdout
      include Fluentd::Setting::Plugin

      register_plugin("output", "stdout")

      def self.initial_params
        {
          pattern: "debug.**",
          buffer_type: "memory",
          buffer: {
            "0" => {
              "type" => "memory",
            }
          },
          format_type: "stdout",
          format: {
            "0" => {
              "@type" => "stdout",
              "output_type" => "json"
            }
          }
        }
      end

      def common_options
        [
          :label, :pattern, :output_type
        ]
      end

      def hidden_options
        [
          :secondary, :inject, :buffer
        ]
      end
    end
  end
end
