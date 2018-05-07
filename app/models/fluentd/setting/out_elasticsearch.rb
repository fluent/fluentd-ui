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
        }
      end

      def common_options
        [
          :match, :host, :port, :logstash_format,
          :index_name, :type_name,
        ]
      end

      def advanced_options
        [
          :hosts, :logstash_prefix, :logstash_dateformat,
          :utc_index, :request_timeout, :include_tag_key,
        ]
      end
    end
  end
end
