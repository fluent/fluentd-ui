class Fluentd
  module Setting
    module SectionConfig
      extend ActiveSupport::Concern

      def to_config
        _attributes = attributes.dup
        if %i(parse format buffer storage).include?(section_name)
          _attributes["@type"] = _attributes.delete("type")
          _attributes["@log_level"] = _attributes.delete("log_level")
        end
        argument = _attributes.delete(self._argument_name.to_s) || ""
        attrs, elements = parse_attributes(_attributes)
        if attrs.present? || elements.present?
          config_element(section_name, argument, attrs.sort.to_h, elements)
        end
      end

      def parse_attributes(attributes)
        sections, params = attributes.partition do |key, _|
          self._sections.key?(key.to_sym)
        end
        elements = sections.map do |key, section_params|
          if section_params.present?
            self._sections[key.to_sym].new(section_params).to_config
          end
        end.compact
        attrs = params.to_h.reject do |key, value|
          skip?(key.to_sym, value)
        end
        unless attrs.blank?
          attrs["@type"] = params.to_h["@type"] if params.to_h.key?("@type")
        end
        return attrs, elements
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
