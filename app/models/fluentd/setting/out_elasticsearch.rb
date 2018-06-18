class Fluentd
  module Setting
    class OutElasticsearch
      include Fluentd::Setting::Plugin

      register_plugin("output", "elasticsearch")

      def self.initial_params
        {
          host: "127.0.0.1",
          port: 9200,
          index_name: "via_fluentd",
          type_name: "via_fluentd",
          logstash_format: true,
          include_tag_key: false,
          utc_index: true,
          buffer_type: "file",
          buffer: {
            "0" => {
              "type" => "file",
              "path" => "/var/log/td-agent/buffer/elasticsearch",
             }
          },
        }
      end

      def common_options
        [
          :pattern, :host, :port, :logstash_format,
          :index_name, :type_name,
        ]
      end

      def hidden_options
        [
          :secondary, :inject, :buffer
        ]
      end
    end
  end
end
