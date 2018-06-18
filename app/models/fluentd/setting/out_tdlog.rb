class Fluentd
  module Setting
    class OutTdlog
      include Fluentd::Setting::Plugin

      register_plugin("output", "tdlog")

      def self.initial_params
        {
          pattern: "td.*.*",
          buffer_type: "file",
          buffer: {
            "0" => {
              "@type" => "file",
              "path" => "/var/log/td-agent/buffer/td",
            }
          },
          auto_create_table: true,
        }
      end

      def common_options
        [
          :pattern, :apikey, :auto_create_table, :database, :table,
        ]
      end

      def hidden_options
        [
          :secondary
        ]
      end
    end
  end
end
