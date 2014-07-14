class Fluentd
  module Setting
    module Common
      extend ActiveSupport::Concern

      module ClassMethods
        attr_accessor :values, :types

        def choice(key, values)
          @values ||= {}
          @values[key] = values
          set_type(:choice, [key])
        end

        def booleans(*keys)
          # e.g.:
          #   use_ssl true
          #   include_time_key false
          set_type(:boolean, keys)
        end

        def flags(*keys)
          # e.g.:
          #   tag_mapped
          #   utc
          set_type(:flag, keys)
        end

        private

        def set_type(type, keys)
          @types ||= {}
          keys.each do |key|
            @types[key] = type
          end
        end
      end

      def values_of(key)
        self.class.values[key] || []
      end

      def column_type(key)
        self.class.types[key] || "string"
      end

      def conf(key)
        case column_type(key)
        when :boolean
          boolenan(key)
        when :flag
          flag(key)
        else
          print_if_present(key)
        end
      end

      def plugin_type_name
        # Fluentd::Setting::OutS3 -> s3
        # Override this method if not above style
        self.class.to_s.split("::").last.sub(/(In|Out)/, "").downcase
      end

      def print_if_present(key)
        # e.g.:
        #   path /var/log/td/aaa
        #   user nobody
        #   retry_limit 3
        send(key).present? ? "#{key} #{send(key)}" : ""
      end

      def boolenan(key)
        send(key).presence == "true" ? "#{key} true" : "#{key} false"
      end

      def flag(key)
        send(key).presence == "true" ? key.to_s : ""
      end

      def to_config
        indent = "  "
        config = "<match #{match}>\n"
        config << "#{indent}type #{plugin_type_name}\n"
        self.class.const_get(:KEYS).each do |key|
          next if key == :match
          config << indent
          config << conf(key)
          config << "\n"
        end
        config << "</match>\n"
        config.gsub(/^[ ]*\n/m, "")
      end
    end
  end
end
