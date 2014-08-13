class Fluentd
  module Setting
    class OutElasticsearch
      include Common

      KEYS = [
        :match,
        :host, :port, :index_name, :type_name,
        :logstash_format, :logstash_prefix, :logstash_dateformat, :utc_index,
        :hosts, :request_timeout, :include_tag_key, :tag_key
      ].freeze

      attr_accessor(*KEYS)

      booleans :logstash_format, :utc_index, :include_tag_key

      validates :match, presence: true
      validates :host, presence: true
      validates :port, presence: true
      validates :index_name, presence: true
      validates :type_name, presence: true
    end
  end
end
