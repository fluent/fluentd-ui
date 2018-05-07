class Fluentd
  module Setting
    class OutTd
      include Fluentd::Setting::Plugin

      register_plugin("output", "tdlog")

      def self.initial_params
        {
          buffer_type: "file",
          buffer_path: "/var/log/td-agent/buffer/td",
          auto_create_table: true,
          match: "td.*.*",
        }
      end

      def common_options
        [
          :match, :apikey, :auto_create_table, :database, :table,
        ]
      end

      def advanced_options
        [
          :flush_interval, :buffer_type, :buffer_path,
        ]
      end
    end
  end
end
