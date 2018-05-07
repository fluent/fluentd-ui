class Fluentd
  module Setting
    class OutS3
      include Fluentd::Setting::Plugin

      register_plugin("output", "s3")

      def self.initial_params
        {
          s3_region: "us-west-1",
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
          :format, :include_time_key, :time_key, :delimiter, :label_delimiter,
          :utc, :time_slice_format, :time_slice_wait, :store_as, :proxy_uri,
          :buffer_type, :buffer_path, :buffer_queue_limit, :buffer_chunk_limit, :flush_interval,
          :retry_wait, :retry_limit, :max_retry_wait, :num_threads,
        ]
      end
    end
  end
end
