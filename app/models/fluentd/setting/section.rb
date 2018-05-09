class Fluentd
  module Setting
    class Section
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Fluentd::Setting::Configurable

      attr_reader :name

      def self.inherited(klass)
        class_attribute :_klass, :_block
        class_attribute :name, :required, :multi, :alias
        self._klass = klass
      end

      def self.model_name
        ActiveModel::Name.new(self, Fluentd::Setting, "Section")
      end

      # Don't overwrite options
      def self.merge(**options)
        self._klass.class_eval(&self._block)
      end

      def initialize(attributes = {})
        self._klass.class_eval(&self._block)
        super(attributes)
      end
    end
  end
end
