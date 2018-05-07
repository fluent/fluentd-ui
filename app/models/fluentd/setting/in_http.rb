class Fluentd
  module Setting
    class InHttp
      include Fluentd::Setting::Plugin

      register_plugin("input", "http")
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
          port: 8888,
          body_size_limit: "32m",
          keepalive_timeout: "10s",
          add_http_headers: false,
          format: "default",
          log_level: "info",
        }
      end

      def common_options
        [
          :bind, :port
        ]
      end

      def advanced_options
        [
          :body_size_limit, :keepalive_timeout, :add_http_headers, :format, :log_level
        ]
      end
    end
  end
end
