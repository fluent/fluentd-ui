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

      self.gem_name = "fluent-plugin-td"

      flags :auto_create_table

      validates :match, presence: true
      validates :apikey, presence: true
      validates :auto_create_table, presence: true
      validates :buffer_path, presence: true, if: ->{ buffer_type == "file" }

      def plugin_name
        "tdlog"
      end

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
