class Fluentd
  module Setting
    class OutForward
      include Fluentd::Setting::Plugin

      register_plugin("output", "forward")

      config_section :secondary do
        config_param :path, :string
      end

      def self.initial_params
        {
          secondary: {
            "0" => {
              type: "file",
            }
          }
        }
      end

      # TODO overwrite this method to support transport parameter and transport section
      # def self.permit_params
      #   super
      # end

      def common_options
        [
          :pattern, :server, :secondary,
        ]
      end

      def hidden_options
        [
          :inject, :buffer,
          :host, :port,
          # We don't support TLS configuration via fluentd-ui for now.
          :transport, :tls_version, :tls_ciphers, :tls_insecure_mode, :tls_verify_hostname, :tls_cert_path
        ]
      end
    end
  end
end
