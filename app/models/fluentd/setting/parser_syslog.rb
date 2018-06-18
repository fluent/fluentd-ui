class Fluentd
  module Setting
    class ParserSyslog
      include Fluentd::Setting::Plugin

      register_plugin("parser", "syslog")
      # Overwrite type of time_format
      config_param(:time_format, :string)

      def self.initial_params
        {}
      end

      def common_options
        [
          :time_format,
          :with_priority,
        ]
      end

      def advanced_options
        [
          :message_format,
          :rfc5424_time_format
        ]
      end
    end
  end
end
