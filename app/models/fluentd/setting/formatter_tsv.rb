class Fluentd
  module Setting
    module FormatterTsv
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "tsv")

      def self.initial_params
        {}
      end
    end
  end
end
