class Fluentd
  module Setting
    class Section
      attr_reader :name

      class << self
        def inherited(klass)
          klass.instance_eval do
            include ActiveModel::Model
            include ActiveModel::Attributes
            include Fluentd::Setting::Configurable
            include Fluentd::Setting::SectionParser
            include Fluentd::Setting::PluginParameter

            class_attribute :_klass, :_block
            class_attribute :name, :required, :multi, :alias
            self._klass = klass
          end
        end

        def init
          _klass.instance_eval(&_block)
        end

        # Don't overwrite options
        def merge(**options)
          _klass.instance_eval(&_block)
        end

        def section?
          true
        end
      end

      def initialize(attributes = {})
        super
      end
    end
  end
end
