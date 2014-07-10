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

      validates :match, presence: true
      validates :api_key, presence: true
      validates :auto_create_table, presence: true
      validates :use_ssl, presence: true

      def to_conf
        <<-XML.strip_heredoc.gsub(/^[ ]*\n/m, "")
        <match #{match}>
          type tdlog
          #{print_if_present :apikey}
          #{auto_create_table.present? ? "auto_create_table" : ""}
          use_ssl #{use_ssl.present? ? "true" : "false"}
          #{print_if_present :database}
          #{print_if_present :table}
          #{print_if_present :endpoint}
          
          #{print_if_present :connect_timeout}
          #{print_if_present :read_timeout}
          #{print_if_present :send_timeout}
          #{print_if_present :flush_interval}
          #{print_if_present :buffer_type}
          #{print_if_present :buffer_path}
        </match>
        XML
      end
    end
  end
end
