class Fluentd
  module Setting
    class OutStdout
      include Fluentd::Setting::Plugin

      register_plugin("output", "stdout")

      def self.initial_params
        {
          pattern: "debug.**",
          output_type: "json",
        }
      end

      def common_options
        [
          :pattern, :output_type
        ]
      end

      def hidden_options
        [
          :secondary
        ]
      end
    end
  end
end
