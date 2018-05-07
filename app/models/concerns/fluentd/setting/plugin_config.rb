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
        build_config(name, argument, _attributes)
      end

      def build_config(name, argument, attributes)
        sections, params = attributes.partition do |key, _section_attributes|
          config_definition.dig(key, :section)
        end
        config = config_element(name, argument, params.to_h.reject{|key, value| value.nil? })
        sections.to_h.each do |key, section_params|
          config.add_element(build_config(key, "", section_params))
        end
        config
      end

      # copy from Fluent::Test::Helpers#config_element
      def config_element(name = 'test', argument = '', params = {}, elements = [])
        Fluent::Config::Element.new(name, argument, params, elements)
      end
    end
  end
end
