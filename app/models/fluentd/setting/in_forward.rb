class Fluentd
  module Setting
    class InForward
      include Fluentd::Setting::Plugin

      register_plugin("input", "forward")
      load_plugin_config do |name, params|
        params.each do |param_name, definition|
          if definition[:section]
            config_section param_name, **definition.slice(:required, :multi, :alias) do
              definition.except(:section, :argument, :required, :multi, :alias).each do |_param_name, _definition|
                config_param _param_name, _definition[:type], **_definition.except(:type)
              end
            end
          else
            config_param param_name, definition[:type], **definition.except(:type)
          end
        end
      end

      def self.initial_params
        {
          bind: "0.0.0.0",
          port: 24224,
          linger_timeout: 0,
          chunk_size_limit: nil,
          chunk_size_warn_limit: nil,
          log_level: "info",
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      # TODO Support <transport>, <security>
      def advanced_options
        [
          :linger_timeout, :chunk_size_limit, :chunk_size_warn_limit, :log_level
        ]
      end
    end
  end
end
