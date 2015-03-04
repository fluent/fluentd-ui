class Fluentd
  module Setting
    class OutMongo
      include Common

      KEYS = [
        :match,
        :host, :port, :database, :collection, :capped, :capped_size, :capped_max, :user, :password, :tag_mapped,
        :buffer_type, :buffer_path, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,  :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
      ].freeze

      attr_accessor(*KEYS)

      flags :capped, :tag_mapped

      validates :match, presence: true
      validates :host, presence: true
      validates :port, presence: true
      validates :database, presence: true
      validate :validate_capped
      validate :validate_collection
      validates :buffer_path, presence: true, if: ->{ buffer_type == "file" }

      def validate_capped
        return true if capped.blank?
        errors.add(:capped_size, :blank) if capped_size.blank?
      end

      def validate_collection
        if tag_mapped.blank? && collection.blank?
          errors.add(:collection, :blank) 
        end
      end

      def self.initial_params
        {
          host: "127.0.0.1",
          port: 27017,
          capped: true,
          capped_size: "100m",
        }
      end

      def common_options
        [
          :match, :host, :port, :database, :collection,
          :tag_mapped, :user, :password,
        ]
      end

      def advanced_options
        [
          :capped, :capped_size, :capped_max, :buffer_type, :buffer_path, :buffer_queue_limit, :buffer_chunk_limit,
          :flush_interval, :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
        ]
      end
    end
  end
end
