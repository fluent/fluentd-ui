class Fluentd
  module Setting
    class OutTd
      include ActiveModel::Model
      include Common

      KEYS = [
        :match,
        :apikey, :auto_create_table, :use_ssl, :database, :table, :endpoint,
        :connect_timeout, :read_timeout, :send_timeout, :flush_interval, :buffer_type, :buffer_path,
      ].freeze

      attr_accessor(*KEYS)

      booleans :use_ssl
      flags :auto_create_table

      validates :match, presence: true
      validates :apikey, presence: true
      validates :auto_create_table, presence: true
      validates :use_ssl, presence: true

      def plugin_name
        "tdlog"
      end

      def to_conf
        to_config
      end
    end
  end
end
