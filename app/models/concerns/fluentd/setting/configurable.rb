class Fluentd
  module Setting
    module Configurable
      extend ActiveSupport::Concern

      included do
        class_attribute :_types, :_defaults, :_secrets, :_aliases, :_required
        class_attribute :_deprecated_params, :_obsoleted_params, :_descriptions
        class_attribute :_list, :_value_types, :_symbolize_keys
        class_attribute :_argument_name, :_built_in_params, :_sections, :_section_params
        self._types = {}
        self._defaults = {}
        self._secrets = {}
        self._aliases = {}
        self._required = {}
        self._deprecated_params = {}
        self._obsoleted_params = {}
        self._descriptions = {}
        self._list = {}
        self._value_types = {}
        self._symbolize_keys = {}
        self._argument_name = nil
        self._built_in_params = []
        self._sections = {}
        self._section_params = Hash.new {|h, k| h[k] = [] }
      end

      def initialize(attributes = {})
        # the superclass does not know specific attributes of the model
        begin
          super
        rescue ActiveModel::UnknownAttributeError => ex
          Rails.logger.warn(ex)
        end
        self.class._sections.each do |name, klass|
          klass.init
          if klass.multi
            next if attributes[name].nil?
            attributes[name].each do |attr|
              next unless attr
              attr.each do |index, _attr|
                self._section_params[name] << klass.new(_attr)
              end
            end
          else
            attr = attributes.dig(name, "0")
            self._section_params[name] << klass.new(attr) if attr
          end
        end
      end

      module ClassMethods
        # config_param :name, :string, default: "value", secret: true
        def config_param(name, type = ActiveModel::Type::Value.new, **options)
          # NOTE: We cannot overwrite types defined by ActiveModel in config/initializers/types.rb
          if type == :time
            type = Fluentd::Setting::Type::Time.new
          end
          if name.to_s.start_with?("@")
            _name = name.to_s[1..-1]
            config_param(_name.to_sym, type, **options.merge(alias: name))
            self._built_in_params << _name
          elsif ["id", "type", "log_level"].include?(name.to_s)
            self._built_in_params << name
            unless name == "type"
              attribute(name, type, **options.slice(:precision, :limit, :scale))
            end
          else
            attribute(name, type, **options.slice(:precision, :limit, :scale))
          end
          self._types[name] = type
          self._descriptions[name] = options[:desc] if options.key?(:desc)
          self._defaults[name] = options[:default] if options.key?(:default)
          self._secrets[name] = options[:secret] if options.key?(:secret)
          self._aliases[name] = options[:alias] if options.key?(:alias)
          self._required[name] = options[:required] if options.key?(:required)
          self._deprecated_params[name] = options[:deprecated] if options.key?(:deprecated)
          self._obsoleted_params[name] = options[:obsoleted] if options.key?(:obsoleted)
          self._list[name] = options[:list] if options.key?(:list)
          self._value_types[name] = options[:value_types] if options.key?(:value_types)
          self._symbolize_keys = options[:symbolize_keys] if options.key?(:symbolize_keys)
        end

        def config_section(name, **options, &block)
          if self._sections.key?(name)
            self._sections[name].merge(**options, &block)
          else
            attribute(name, :section)
            section_class = Class.new(::Fluentd::Setting::Section)
            section_class.section_name = name
            section_class.required = options[:required]
            section_class.multi = options[:multi]
            section_class.alias = options[:alias]
            section_class._block = block
            self.const_set(name.to_s.classify, section_class)
            self._sections[name] = section_class
          end
        end

        def config_argument(name, type = ActiveModel::Type::Value.new, **options)
          config_param(name, type, **options)
          self._argument_name = name
        end

        def set_argument_name(name)
          self._argument_name = name
        end
      end
    end
  end
end
