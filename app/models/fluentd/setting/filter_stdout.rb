class Fluentd
  module Setting
    class FilterStdout
      include Fluentd::Setting::Plugin

      register_plugin("filter", "stdout")

      def self.initial_params
        {
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
          :pattern,
        ]
      end

      def hidden_options
        [
          :inject
        ]
      end
    end
  end
end
