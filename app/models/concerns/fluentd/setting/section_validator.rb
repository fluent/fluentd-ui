class Fluentd
  module Setting
    module SectionValidator
      extend ActiveSupport::Concern

      included do
        validate :validate_sections
      end

      def validate_sections
        self._section_params.each do |name, sections|
          sections.each do |section|
            next if section.attributes.values.all?(&:blank?)
            if section.invalid?
              errors.add(name, :invalid, message: section.errors.full_messages)
            end
          end
        end
      end
    end
  end
end
