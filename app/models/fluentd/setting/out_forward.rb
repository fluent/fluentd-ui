class Fluentd
  module Setting
    class OutForward
      include Fluentd::Setting::Plugin

      register_plugin("output", "forward")

      config_section :secondary do
        config_param :path, :string
      end

      def self.initial_params
        params = {
          buffer_type: "memory",
          buffer: {
            "0" => {
              "type" => "memory",
            }
          },
          secondary: {
            "0" => {
              "type" => "file",
            }
          }
        }
        super.except(:transport).compact.deep_merge(params)
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
          # Deprecated options
          :host, :port,
          :transport
        ].concat(tls_options) # Hide TLS related options to customize view
      end

      def tls_options
        [
          :tls_version,
          :tls_ciphers,
          :tls_insecure_mode,
          :tls_allow_self_signed_cert,
          :tls_verify_hostname,
          :tls_cert_path
        ]
      end
    end
  end
end
