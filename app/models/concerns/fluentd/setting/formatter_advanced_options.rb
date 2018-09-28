class Fluentd
  module Setting
    module FormatterAdvancedOptions
      extend ActiveSupport::Concern

      def advanced_options
        [
          :time_type,
          :time_format,
          :timezone,
          :utc,
        ]
      end

      def hidden_options
        [
          :localtime
        ]
      end
    end
  end
end
