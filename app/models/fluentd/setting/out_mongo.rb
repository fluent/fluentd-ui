class Fluentd
  module Setting
    class OutMongo
      include ActiveModel::Model

      KEYS = [
        :match,
        :host, :port, :database, :collection, :capped, :capped_size, :capped_max, :user, :password, :tag_mapped,
        :buffer_type, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,  :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
      ].freeze

      attr_accessor(*KEYS)

      validates :match, presence: true
      validates :host, presence: true
      validates :port, presence: true
      validates :database, presence: true
      validate :validate_capped
      validate :validate_collection

      def to_conf
        <<-XML.strip_heredoc.gsub(/^[ ]*\n/m, "")
        <match *.*>
          type mongo
          #{print_if_present :host}
          #{print_if_present :port}
          #{print_if_present :database}
          #{print_if_present :collection}
          #{print_if_present :user}
          #{print_if_present :password}

          #{self.capped.present? ? "capped" : ""}
          #{print_if_present :capped_size}
          #{print_if_present :capped_max}
          
          #{self.tag_mapped.present? ? "tag_mapped" : ""}
          #{print_if_present :buffer_type}
          #{print_if_present :buffer_queue_limit}
          #{print_if_present :buffer_chunk_limit}
          #{print_if_present :flush_interval}
          #{print_if_present :retry_wait}
          #{print_if_present :retry_limit}
          #{print_if_present :max_retry_wait}
          #{print_if_present :num_threads}
        </match>
        XML
      end

      def print_if_present(key)
        send(key).present? ? "#{key} #{send(key)}" : ""
      end

      def validate_capped
        return true if capped.blank?
        errors.add(:capped_size, :blank) if capped_size.blank?
      end

      def validate_collection
        if tag_mapped.blank? && collection.blank?
          errors.add(:collection, :blank) 
        end
      end
    end
  end
end
