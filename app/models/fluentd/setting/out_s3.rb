class Fluentd
  module Setting
    class OutS3
      include ActiveModel::Model
      include Common

      KEYS = [
        :match,
        :aws_key_id, :aws_sec_key, :s3_bucket, :s3_endpoint, :path,
        # :reduced_redundancy, :check_apikey_on_start, :command_parameter, # not configurable?
        :format, :include_time_key, :time_key, :delimiter, :label_delimiter, :add_newline, :output_tag, :output_time,
        :time_slice_format, :time_slice_wait, :time_format, :utc, :store_as, :proxy_uri, :use_ssl,
        :buffer_type, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,
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
    end
  end
end
