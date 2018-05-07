class Fluentd
  module Setting
    module PluginConfig
      extend ActiveSupport::Concern

      def to_config2
        name = case plugin_type
               when "input"
                 "source"
               when "output"
                 "match"
               when "filter"
                 "filter"
               when "parser"
                 "parse"
               when "formatter"
                 "format"
               when "buffer"
                 "buffer"
               end
        _argument_name
        argument = case plugin_type
                   when "match", "filter", "buffer"
                     attributes(_argument_name)
                   else
                     ""
                   end
        _attributes = { "@type" => self.plugin_name }.merge(attributes)
        attrs, elements = parse_attributes(_attributes)
        config_element(name, argument, attrs, elements)
      end

      def parse_attributes(attributes)
        base_klasses = config_definition.keys
        sections, params = attributes.partition do |key, _section_attributes|
          base_klasses.any? do |base_klass|
            config_definition.dig(base_klass, key.to_sym, :section) || config_definition.dig(key.to_sym, :section)
          end
        end
        elements = []
        sections.to_h.each do |key, section_params|
          next if section_params.nil?
          section_params.each do |index, _section_params|
            sub_attrs, sub_elements = parse_attributes(_section_params)
            elements << config_element(key, "", sub_attrs, sub_elements)
          end
        end
        return params.to_h.reject{|key, value| value.nil? }, elements
      end

      # copy from Fluent::Test::Helpers#config_element
      def config_element(name = 'test', argument = '', params = {}, elements = [])
        Fluent::Config::Element.new(name, argument, params, elements)
      end
    end
  end
end
