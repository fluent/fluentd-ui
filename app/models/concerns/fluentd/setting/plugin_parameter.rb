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
      end
    end
  end
end
