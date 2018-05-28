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
