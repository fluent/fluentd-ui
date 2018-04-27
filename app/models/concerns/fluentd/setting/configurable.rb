class Fluentd
  module Setting
    module Configurable
      extend ActiveSupport::Concern

      included do
        class_attribute :_secrets, :_aliases, :_deprecated_params, :_obsoleted_params, :_descriptions
        class_attribute :_list, :_value_types, :_symbolize_keys
        class_attribute :_argument_name, :_built_in_params
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
      end

      module ClassMethods
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
          end
          self._secrets[name] = options[:secret] if options.key?(:secret)
          self._aliases[name] = options[:alias] if options.key?(:alias)
          self._deprecated_params[name] = options[:deprecated] if options.key?(:deprecated)
          self._obsoleted_params[name] = options[:obsoleted] if options.key?(:obsoleted)
          self._list[name] = options[:list] if options.key?(:list)
          self._value_types[name] = options[:value_types] if options.key?(:value_types)
          self._symbolize_keys = options[:symbolize_keys] if options.key?(:symbolize_keys)
        end

        def config_section(name, **options)
          # TODO
        end

        def set_argument_name(name)
          self._argument_name = name
        end
      end
    end
  end
end
