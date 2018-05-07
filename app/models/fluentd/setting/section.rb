class Fluentd
  module Setting
    class Section
      include Fluentd::Setting::Configurable

      attr_reader :name

      # required, multi, alias
      def initialize(name, **options, &block)
        @name = name
        @required = options[:required]
        @multi = options[:multi]
        @alias = options[:alias]
        block.call
      end

      # Don't overwrite options
      def merge(**options, &block)
        block.call
      end
    end
  end
end
