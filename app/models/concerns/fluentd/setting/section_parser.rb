class Fluentd
  module Setting
    module SectionParser
      extend ActiveSupport::Concern

      module ClassMethods
        def parse_section(name, definition)
          config_section(name, **definition.slice(:required, :multi, :alias)) do
            definition.except(:section, :argument, :required, :multi, :alias).each do |_param_name, _definition|
              if _definition[:section]
                parse_section(_param_name, _definition)
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
