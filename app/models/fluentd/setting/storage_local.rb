class Fluentd
  module Setting
    class StorageLocal
      include Fluentd::Setting::Plugin

      register_plugin("storage", "local")

      def self.initial_params
        {}
      end

      def common_options
        [
          :path,
          :mode,
          :dir_mode,
          :pretty_print
        ]
      end
    end
  end
end
