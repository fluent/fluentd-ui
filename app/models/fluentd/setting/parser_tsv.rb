class Fluentd
  module Setting
    class ParserTsv
      include Fluentd::Setting::Plugin

      register_plugin("parser", "tsv")

      def self.initial_params
        {}
      end
    end
  end
end
