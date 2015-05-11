class Fluentd
  module Setting
    module Common
      extend ActiveSupport::Concern
      include ActiveModel::Model

      module ClassMethods
        attr_accessor :values, :types, :children, :hidden_values

        def choice(key, values)
          @values ||= {}
          @values[key] = values
          set_type(:choice, [key])
        end

        def hidden(key)
          set_type(:hidden, [key])
        end

        def nested(key, klass, options = {})
          # e.g.:
          #  <match>
          #    type forward
          #    <server>
          #      ..
          #    </server>
          #  </match>
          @children ||= {}
          @children[key] = {
            class: klass,
            options: options,
          }
          set_type(:nested, [key])
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

        def gem_name
          @gem_name
        end

        def gem_name=(name)
          @gem_name ||= name
        end

        def required_fields
          instance = new(initial_params)
          # https://github.com/cowbell/active_model-errors_details
          instance.valid?
          details = instance.errors.details
          details.keys.find_all do |key|
            details[key].find{|error| error[:error] == :blank}
          end
        end

        def plugin
          return unless gem_name
          Plugin.new(gem_name: gem_name)
        end

        private

        def set_type(type, keys)
          @types ||= {}
          keys.each do |key|
            @types[key] = type
          end
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
        when :boolean
          boolenan(key)
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

      def to_config(elm_name = nil)
        indent = "  "
        if elm_name
          config = "<#{elm_name}>\n"
        else
          if input_plugin?
            config = "<source>\n"
          else
            config = "<match #{match}>\n"
          end
          config << "#{indent}type #{plugin_type_name}\n"
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
