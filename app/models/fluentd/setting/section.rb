class Fluentd
  module Setting
    class Section
      class << self
        def inherited(klass)
          klass.instance_eval do
            include ActiveModel::Model
            include ActiveModel::Attributes
            include Fluentd::Setting::Configurable
            include Fluentd::Setting::SectionParser
            include Fluentd::Setting::PluginParameter

            class_attribute :_klass, :_block, :_blocks
            class_attribute :section_name, :required, :multi, :alias
            self._klass = klass
            self._blocks = []
          end
        end

        def init
          _klass.instance_eval(&_block)
          _blocks.each do |b|
            _klass.instance_eval(&b)
          end
        end

        # Don't overwrite options
        def merge(**options, &block)
          _blocks << block
        end

        def section?
          true
        end
      end
    end
  end
end
