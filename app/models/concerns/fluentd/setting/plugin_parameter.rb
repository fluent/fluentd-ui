class Fluentd
  module Setting
    module PluginParameter
      extend ActiveSupport::Concern

      include Fluentd::Setting::Configurable

      def column_type(name)
        self.class._types[name]
      end

      def list_of(name)
        self.class._list[name]
      end

      def desc(name)
        self.class._descriptions[name]
      end

      def default(name)
        reformat_value(name, self.class._defaults[name])
      end

      def common_options
        []
      end

      def advanced_options
        all_options - common_options - hidden_options
      end

      def hidden_options
        []
      end

      def all_options
        self.class._types.keys + self.class._sections.keys
      end

      def have_buffer_section?
        self.class._sections.key?(:buffer)
      end

      def have_storage_section?
        self.class._sections.key?(:storage)
      end

      def have_parse_section?
        self.class._sections.key?(:parse)
      end

      def have_format_section?
        self.class._sections.key?(:format)
      end

      def create_buffer
        return unless have_buffer_section?
        buffer_class = Fluentd::Setting.const_get("buffer_#{buffer_type}".classify)
        buffer_class.new(buffer["0"].except("type"))
      end

      def create_storage
        return unless have_storage_section?
        storage_class = Fluentd::Setting.const_get("storage_#{storage_type}".classify)
        storage_class.new(storage["0"].except("type"))
      end

      def create_parser
        return unless have_parse_section?
        parser_class = Fluentd::Setting.const_get("parser_#{parse_type}".classify)
        parser_class.new(parse["0"].except("type"))
      end

      def create_formatter
        return unless have_format_section?
        formatter_class = Fluentd::Setting.const_get("formatter_#{format_type}".classify)
        formatter_class.new(format["0"].except("type"))
      end

      def reformat_value(name, value)
        type = column_type(name)
        return value if type.nil? # name == :time_key
        return value if type == :enum
        return value if type == :regexp
        type_name = if type.is_a?(Fluentd::Setting::Type::Time)
                      :time
                    else
                      type
                    end
        Fluent::Config::REFORMAT_VALUE.call(type_name, value)
      end

      module ClassMethods
        def column_type(name)
          self._types[name]
        end

        def list_of(name)
          self._list[name]
        end

        def permit_params
          self.new # init
          keys = self._types.keys
          self._sections.each do |key, section|
            keys << _permit_section(key, section)
          end
          keys
        end

        def _permit_section(key, section)
          keys = { key => section._types.keys }
          section._sections.each do |_key, _section|
            keys << _permit_section(_key, _section)
          end
          keys
        end
      end
    end
  end
end
