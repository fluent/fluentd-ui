require "fluent/plugin"
require "fluent/test/log"
require "fluent/test/driver/input"
require "fluent/test/driver/output"
require "fluent/test/driver/filter"
require "fluent/test/driver/parser"
require "fluent/test/driver/formatter"

class Fluentd
  module Setting
    module Plugin
      extend ActiveSupport::Concern

      include ActiveModel::Model
      include ActiveModel::Attributes
      include Fluentd::Setting::Configurable
      include Fluentd::Setting::PluginConfig
      include Fluentd::Setting::SectionParser
      include Fluentd::Setting::PluginParameter

      included do
        cattr_accessor :plugin_type, :plugin_name, :config_definition
      end

      module ClassMethods
        def register_plugin(type, name)
          self.plugin_type = type
          self.plugin_name = name

          if ["filter", "output"].include?(type)
            include Fluentd::Setting::Pattern
          end

          self.load_plugin_config do |_name, params|
            params.each do |param_name, definition|
              if definition[:section]
                parse_section(param_name, definition)
                if %i(buffer storage parse format).include?(param_name)
                  attribute("#{param_name}_type", :string)
                end
              else
                config_param(param_name, definition[:type], **definition.except(:type))
              end
            end
          end
        end

        def load_plugin_config
          dumped_config = {}
          plugin_class.ancestors.reverse_each do |klass|
            next unless klass.respond_to?(:dump_config_definition)
            dumped_config_definition = klass.dump_config_definition
            dumped_config[klass.name] = dumped_config_definition unless dumped_config_definition.empty?
          end
          self.config_definition = dumped_config
          dumped_config.each do |name, config|
            yield name, config
          end
        end

        def plugin_instance
          @plugin_instance ||= Fluent::Plugin.__send__("new_#{plugin_type}", plugin_name)
        end

        def plugin_class
          @plugin_class ||= plugin_instance.class
        end

        def create_driver(config)
          case plugin_type
          when "input"
            if plugin_class.class_variable_defined?(:@@pos_file_paths)
              plugin_class.class_variable_set(:@@pos_file_paths, {})
            end
            Fluent::Test::Driver::Input.new(plugin_class).configure(config)
          when "output"
            if Fluent::Plugin::FileBuffer.class_variable_defined?(:@@buffer_paths)
              Fluent::Plugin::FileBuffer.class_variable_set(:@@buffer_paths, {})
            end
            Fluent::Test::Driver::Output.new(plugin_class).configure(config)
          when "filter"
            Fluent::Test::Driver::Filter.new(plugin_class).configure(config)
          when "parser"
            Fluent::Test::Driver::Parser.new(plugin_class).configure(config)
          when "formatter"
            FLuent::Test::Driver::Formatter.new(plugin_class).configure(config)
          else
            nil
          end
        end

        def plugin_helpers
          @plugin_helpers ||= if plugin_instance.respond_to?(:plugin_helpers)
                                plugin_instance.plugin_helpers
                              else
                                []
                              end
        end

        def section?
          false
        end
      end
    end
  end
end
