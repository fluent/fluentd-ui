class Fluentd
  module Setting
    module ParserAdvancedOptions
      extend ActiveSupport::Concern

      def advanced_options
        [
          :types,
          :null_value_pattern,
          :null_empty_string,
          :estimate_current_event,
          :time_key,
          :time_type,
          :time_format,
          :keep_time_key,
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
