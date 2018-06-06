class Fluentd
  module Setting
    class ParserLtsv
      include Fluentd::Setting::Plugin

      register_plugin("parser", "ltsv")

      def self.initial_params
        {
          delimiter: "\t",
          delimiter_pattern: nil,
          label_delimiter: ":"
        }
      end
    end
  end
end
