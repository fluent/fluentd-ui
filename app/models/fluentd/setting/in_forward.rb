class Fluentd
  module Setting
    class InForward
      include Fluentd::Setting::Plugin

      register_plugin("input", "forward")

      def common_options
        [
          :label,
          :bind, :port
        ]
      end

      def hidden_options
        [
          # We don't support TLS configuration via fluentd-ui for now.
          :transport,
          :backlog,
          :blocking_timeout,
        ]
      end

      def transport_common_options
        [
          :ca_path,
          :cert_path,
          :private_key_path,
          :private_key_passphrase
        ]
      end

      def transport_advanced_options
        [
          :version,
          :ciphers,
          :insecure,
          :client_cert_auth,
          :ca_cert_path,
          :ca_private_key_path,
          :ca_private_key_passphrase,
          :generate_private_key_length,
          :generate_cert_country,
          :generate_cert_state,
          :generate_cert_locality,
          :generate_cert_common_name,
          :generate_cert_common_name,
          :generate_cert_expiration,
          :generate_cert_digest
        ]
      end
    end
  end
end
