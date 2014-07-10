class Fluentd
  module Setting
    module Common
      def print_if_present(key)
        send(key).present? ? "#{key} #{send(key)}" : ""
      end
    end
  end
end
