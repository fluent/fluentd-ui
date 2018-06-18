class Fluentd
  module Setting
    class OutS3
      include Fluentd::Setting::Plugin

      register_plugin("output", "s3")

      def self.initial_params
        {
          s3_region: "us-west-1",
          buffer_type: "file",
          buffer: {
            "0" => {
              "type" => "file",
              "path" => "/var/log/td-agent/buffer/s3",
            }
          },
          format_type: "out_file",
          format: {
            "0" => {
              "type" => "out_file"
            }
          }
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
