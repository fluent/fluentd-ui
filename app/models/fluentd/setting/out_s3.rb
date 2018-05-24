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
          :pattern, :aws_key_id, :aws_sec_key,
          :s3_region, :s3_bucket, :use_ssl, :path,
        ]
      end

      def hidden
        [
          :secondary, :inject, :buffer
        ]
      end
    end
  end
end
