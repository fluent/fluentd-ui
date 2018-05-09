require "fluent/plugin"

class Fluentd
  module Setting
    module Plugin
      extend ActiveSupport::Concern

      include ActiveModel::Model
      include ActiveModel::Attributes
      include Fluentd::Setting::Configurable
      include Fluentd::Setting::PluginConfig
      include Fluentd::Setting::SectionValidator

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
                config_section(param_name, **definition.slice(:required, :multi, :alias)) do
                  definition.except(:section, :argument, :required, :multi, :alias).each do |_param_name, _definition|
                    next if _definition[:section]
                    config_param(_param_name, _definition[:type], **_definition.except(:type))
                  end
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

        def plugin_helpers
          @plugin_helpers ||= if plugin_instance.respond_to?(:plugin_helpers)
                                plugin_instance.plugin_helpers
                              else
                                []
                              end
        end
      end
    end
  end
end
