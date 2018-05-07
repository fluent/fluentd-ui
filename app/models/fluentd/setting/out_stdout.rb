class Fluentd
  module Setting
    class OutStdout
      include Fluentd::Setting::Plugin

      register_plugin("output", "stdout")

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
    end
  end
end
