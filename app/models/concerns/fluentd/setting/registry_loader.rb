class Fluentd
  module Setting
    module RegistryLoader
      extend ActiveSupport::Concern

      module ClassMethods
        def define_all_attributes(section_name)
          registry = case section_name
                     when :buffer
                       Fluent::Plugin::BUFFER_REGISTRY
                     when :storage
                       Fluent::Plugin::STORAGE_REGISTRY
                     when :parse
                       Fluent::Plugin::PARSER_REGISTRY
                     when :format
                       Fluent::Plugin::FORMATTER_REGISTRY
                     end
          registry.map.each do |key, plugin_class|
            plugin_class.ancestors.reverse_each do |klass|
              next unless klass.respond_to?(:dump_config_definition)
              begin
                dumped_config_definition = klass.dump_config_definition
                self._dumped_config[klass.name] = dumped_config_definition unless dumped_config_definition.empty?
              rescue NoMethodError
              end
            end
          end
          attribute(:type, :string)
          self._dumped_config.values.map(&:keys).flatten.uniq.each do |name|
            attribute(name, :object)
          end
        end
      end
    end
  end
end
