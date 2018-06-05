class Fluentd
  module Setting
    module FormatterHash
      include Fluentd::Setting::Plugin

      register_plugin("formatter", "hash")

      def self.initial_params
        {}
      end
    end
  end
end
