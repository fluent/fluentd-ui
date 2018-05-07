class Fluentd
  module Setting
    module Configurable
      extend ActiveSupport::Concern

      included do
        class_attribute :_defaults, :_secrets, :_aliases
        class_attribute :_deprecated_params, :_obsoleted_params, :_descriptions
        class_attribute :_list, :_value_types, :_symbolize_keys
        class_attribute :_argument_name, :_built_in_params, :_sections
        self._defaults = {}
        self._secrets = {}
        self._aliases = {}
        self._deprecated_params = {}
        self._obsoleted_params = {}
        self._descriptions = {}
        self._list = {}
        self._value_types = {}
        self._symbolize_keys = {}
        self._argument_name = nil
        self._built_in_params = []
        self._sections = {}
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
            config_param(_name.to_sym, type, **options)
            self._built_in_params << _name
          else
            attribute(name, type, **options.slice(:precision, :limit, :scale))
            validates name, presence: true unless options.key?(:default)
          end
          self._defaults[name] = options[:default] if options.key?(:default)
          self._secrets[name] = options[:secret] if options.key?(:secret)
          self._aliases[name] = options[:alias] if options.key?(:alias)
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
            cattr_accessor name
            self._sections[name] = ::Fluentd::Setting::Section.new(name, **options, &block)
            self.__send__("#{name}=", self._sections[name])
          end
        end

        def set_argument_name(name)
          self._argument_name = name
        end
      end
    end
  end
end