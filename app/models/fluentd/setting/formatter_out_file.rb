class Fluentd
  module Setting
    module FormatterOutFile
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "out_file")

      def self.initial_params
        {}
      end
    end
  end
end
