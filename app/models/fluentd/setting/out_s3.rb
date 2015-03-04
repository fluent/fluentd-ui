class Fluentd
  module Setting
    class OutS3
      include ActiveModel::Model
      include Common

      KEYS = [
        :match,
        :aws_key_id, :aws_sec_key, :s3_bucket, :s3_region, :path,
        # :reduced_redundancy, :check_apikey_on_start, :command_parameter, # not configurable?
        :format, :include_time_key, :time_key, :delimiter, :label_delimiter, :add_newline, :output_tag, :output_time,
        :time_slice_format, :time_slice_wait, :time_format, :utc, :store_as, :proxy_uri, :use_ssl,
        :buffer_type, :buffer_path, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,
        :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
      ].freeze

      attr_accessor(*KEYS)

      choice :format, %w(out_file json ltsv single_value)
      choice :store_as, %w(gzip lzo lzma2 json txt)
      choice :buffer_type, %w(memory file)
      booleans :include_time_key, :add_newline, :use_ssl, :output_tag, :output_time
      flags :utc

      validates :match, presence: true
      validates :s3_bucket, presence: true
      validates :buffer_path, presence: true, if: ->{ buffer_type == "file" }

      def self.initial_params
        {
          s3_region: "us-west-1",
          output_tag: true,
          output_time: true,
          use_ssl: true,
        }
      end

      def common_options
        [
          :match, :aws_key_id, :aws_sec_key,
          :s3_region, :s3_bucket, :use_ssl, :path,
        ]
      end

      def advanced_options
        [
          :format, :output_tag, :output_time, :include_time_key, :time_key, :delimiter, :label_delimiter,
          :utc, :time_slice_format, :time_slice_wait, :store_as, :proxy_uri,
          :buffer_type, :buffer_path, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,
          :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
        ]
      end
    end
  end
end
