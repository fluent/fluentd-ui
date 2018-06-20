class Fluentd
  module Setting
    module PluginConfig
      extend ActiveSupport::Concern

      def to_config
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
               when "storage"
                 "storage"
               end
        _attributes = attributes.reject do |key, value|
          %w(parse_type format_type buffer_type storage_type).include?(key.to_s)
        end
        _attributes = { "@type" => self.plugin_name }.merge(_attributes)
        _attributes["@log_level"] = _attributes.delete("log_level")
        argument = case plugin_type
                   when "output", "filter", "buffer"
                     _attributes.delete(self._argument_name.to_s) || ""
                   else
                     ""
                   end
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
          if %w(parse format buffer storage).include?(key)
            if section_params && section_params.key?("0")
              section_params["0"] = { "@type" => self.attributes["#{key}_type"] }.merge(section_params["0"])
            else
              section_params = {
                "0" => { "@type" => self.attributes["#{key}_type"] }
              }
            end
          end
          next if section_params.blank?
          section_params.each do |index, _section_params|
            sub_attrs, sub_elements = parse_attributes(_section_params)
            if sub_attrs.present? || sub_elements.present? # skip empty section
              elements << config_element(key, "", sub_attrs, sub_elements)
            end
          end
        end
        return params.to_h.reject{|key, value| skip?(key.to_sym, value) }, elements
      end

      # copy from Fluent::Test::Helpers#config_element
      def config_element(name = 'test', argument = '', params = {}, elements = [])
        Fluent::Config::Element.new(name, argument, params, elements)
      end

      def skip?(key, value)
        return true if value.blank?
        if self._defaults.key?(key)
          self.class.reformat_value(key, self._defaults[key]) == self.class.reformat_value(key, value)
        else
          false
        end
      end
    end
  end
end
