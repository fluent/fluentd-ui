class Fluentd
  module Setting
    class BufferMemory
      include Fluentd::Setting::Plugin

      register_plugin("buffer", "memory")

      def self.initial_params
        {}
      end

      def common_options
        []
      end
    end
  end
end
