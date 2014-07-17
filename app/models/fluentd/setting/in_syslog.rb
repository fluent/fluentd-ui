class Fluentd
  module Setting
    class InSyslog
      include ActiveModel::Model
      include Common

      KEYS = [
        :port, :bind, :tag, :types
      ].freeze

      attr_accessor(*KEYS)

      validates :tag, presence: true

      def to_conf
        <<-XML.strip_heredoc.gsub(/^[ ]*\n/m, "")
        <source>
          type syslog
          #{print_if_present :tag}
          #{print_if_present :bind}
          #{print_if_present :port}
          #{print_if_present :types}
        </source>
        XML
      end
    end
  end
end
