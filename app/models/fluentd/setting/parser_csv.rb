class Fluentd
  module Setting
    class ParserCsv
      include Fluentd::Setting::Plugin

      register_plugin("parser", "csv")

      def self.initial_params
        {
          keys: nil,
          delimiter: ","
        }
      end

      def common_options
        [
          :keys, :delimiter
        ]
      end
    end
  end
end
