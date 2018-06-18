class Fluentd
  module Setting
    class OutMongo
      include Fluentd::Setting::Plugin

      register_plugin("output", "mongo")
      config_param(:capped, :bool, default: false)
      config_param(:capped_size, :size, default: nil)

      # NOTE: fluent-plugin-mongo defines database parameter as required parameter
      #       But Fluentd tells us that the database parameter is not required.
      validates :database, presence: true
      validate :validate_collection

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
          buffer_type: "file",
          buffer: {
            "0" => {
              "type" => "file",
              "path" => "/var/log/td-agent/buffer/mongo",
            }
          },
         }
      end

      def common_options
        [
          :pattern, :host, :port, :database, :collection,
          :tag_mapped, :user, :password,
        ]
      end

      def hidden_options
        [
          :secondary, :inject, :buffer,
          :include_tag_key,
          :include_time_key
        ]
      end
    end
  end
end
