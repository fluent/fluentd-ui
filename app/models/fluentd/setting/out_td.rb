class Fluentd
  module Setting
    class OutTd
      include ActiveModel::Model
      include Common

      KEYS = [
        :match,
        :apikey, :auto_create_table, :database, :table,
        :flush_interval, :buffer_type, :buffer_path,
      ].freeze

      attr_accessor(*KEYS)

      flags :auto_create_table

      validates :match, presence: true
      validates :apikey, presence: true
      validates :auto_create_table, presence: true

      def plugin_name
        "tdlog"
      end
    end
  end
end
