class Fluentd
  module Setting
    module SectionParser
      extend ActiveSupport::Concern

      module ClassMethods
        def parse_section(name, definition)
          config_section(name, **definition.slice(:required, :multi, :alias)) do
            if %i(buffer storage parse format).include?(name)
              define_all_attributes(name)
            else
              definition.except(:section, :argument, :required, :multi, :alias).each do |_param_name, _definition|
                if _definition[:section]
                  parse_section(_param_name, _definition)
                else
                  if self._types.key?(_param_name)
                    if _definition.key?(:default) && self._required[_param_name] && _definition[:default].present?
                      self._defaults[_param_name] = _definition[:default]
                      self._required[_param_name] = false
                    end
                    self._secrets[_param_name] = _definition[:secret] if _definition.key?(:secret)
                    self._aliases[name] = _definition[:alias] if _definition.key?(:alias)
                    self._deprecated_params[name] = _definition[:deprecated] if _definition.key?(:deprecated)
                    self._obsoleted_params[name] = _definition[:obsoleted] if _definition.key?(:obsoleted)
                    self._list[name] = _definition[:list] if _definition.key?(:list)
                    self._value_types[name] = _definition[:value_types] if _definition.key?(:value_types)
                    self._symbolize_keys = _definition[:symbolize_keys] if _definition.key?(:symbolize_keys)
                  else
                    if _definition[:argument]
                      config_argument(_param_name, _definition[:type], **_definition.except(:type))
                    else
                      config_param(_param_name, _definition[:type], **_definition.except(:type))
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
