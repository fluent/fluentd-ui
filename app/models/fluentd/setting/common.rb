require "fluent/command/plugin_config_formatter"

class Fluentd
  module Setting
    module Common
      extend ActiveSupport::Concern

      module ClassMethods
        attr_accessor :values, :types, :children, :hidden_values

        def hidden(key)
          set_type(:hidden, key)
        end

        def nested(key, klass, options = {})
          # e.g.:
          #  <match>
          #    @type forward
          #    <server>
          #      ..
          #    </server>
          #  </match>
          @children ||= {}
          @children[key] = {
            class: klass,
            options: options,
          }
          set_type(:nested, key)
        end

        private

        def set_type(type, key)
          @types ||= {}
          @types[key] = type
        end
      end

      def children_of(key)
        meta = self.class.children[key]
        return unless meta
        klass = meta[:class]
        data = send(key) || {"0" => {}}
        children = []
        data.each_pair do |index, attrs|
          children << klass.new(attrs)
        end
        children
      end

      def child_class(key)
        self.class.children[key][:class]
      end

      def values_of(key)
        self.class.values.try(:[], key) || []
      end

      def column_type(key)
        self.class.types.try(:[], key) || "string"
      end

      def conf(key)
        case column_type(key)
        when :bool
          bool(key)
        when :flag
          flag(key)
        when :nested
          return "" unless send(key)
          klass = child_class(key)
          send(key).map do |(_, child)|
            # send("servers")
            #
            # "servers" => {
            #   "0" => {
            #     "name" => "foo",
            #     "host" => "bar",
            #     ..
            #   },
            #   "1" => {
            #     ..
            #   }
            # }
            child_instance = klass.new(child)
            unless child_instance.empty_value?
              "\n" + child_instance.to_config(key).gsub(/^/m, "  ")
            end
          end.join
        else # including :hidden
          print_if_present(key)
        end
      end

      def plugin_type_name
        # Fluentd::Setting::OutS3 -> s3
        # Override this method if not above style
        try(:plugin_name) || self.class.to_s.split("::").last.sub(/(In|Out)/, "").downcase
      end

      def print_if_present(key)
        # e.g.:
        #   @type file
        #   @log_level debug
        #   path /var/log/td/aaa
        #   user nobody
        #   retry_limit 3
        case key
        when :type, :log_level
          send(key).present? ? "@#{key} #{send(key)}" : ""
        else
          send(key).present? ? "#{key} #{send(key)}" : ""
        end
      end

      def bool(key)
        send(key).presence == "true" ? "#{key} true" : "#{key} false"
      end

      def flag(key)
        send(key).presence == "true" ? key.to_s : ""
      end

      def empty_value?
        config = ""
        self.class.const_get(:KEYS).each do |key|
          config << conf(key)
        end
        config.empty?
      end

      def input_plugin?
        self.class.to_s.match(/::In|^In/)
      end

      def output_plugin?
        not input_plugin?
      end

      def to_config_old(elm_name = nil)
        indent = "  "
        if elm_name
          config = "<#{elm_name}>\n"
        else
          if input_plugin?
            config = "<source>\n"
          else
            config = "<match #{match}>\n"
          end
          config << "#{indent}@type #{plugin_type_name}\n"
        end
        self.class.const_get(:KEYS).each do |key|
          next if key == :match
          config << indent
          config << conf(key)
          config << "\n"
        end
        if elm_name
          config << "</#{elm_name}>\n"
        else
          if input_plugin?
            config << "</source>\n"
          else
            config << "</match>\n"
          end
        end
        config.gsub(/^[ ]*\n/m, "")
      end
    end
  end
end
