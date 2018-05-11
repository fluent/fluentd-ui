class Fluentd
  module Setting
    class OutTdlog
      include Fluentd::Setting::Plugin

      register_plugin("output", "tdlog")

      def self.initial_params
        {
          pattern: "td.*.*",
          buffer: {
            "@type" => "file",
            "path" => "/var/log/td-agent/buffer/td",
          },
          auto_create_table: true,
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
