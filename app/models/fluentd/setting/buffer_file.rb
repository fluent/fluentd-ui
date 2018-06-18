class Fluentd
  module Setting
    class BufferFile
      include Fluentd::Setting::Plugin

      register_plugin("buffer", "file")

      def self.initial_params
        {
          path: ""
        }
      end

      def common_options
        [
          :path,
          :file_permission,
          :dir_permission
        ]
      end
    end
  end
end
