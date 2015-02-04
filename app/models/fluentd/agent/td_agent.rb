class Fluentd
  class Agent
    class TdAgent
      include Common
      include LocalCommon

      def self.default_options
        {
          :pid_file => "/var/run/td-agent/td-agent.pid",
          :log_file => "/var/log/td-agent/td-agent.log",
          :config_file => "/etc/td-agent/td-agent.conf",
        }
      end

      def version
        `/usr/sbin/td-agent --version`.strip
      end

      def dryrun!(file_path = nil)
        Bundler.with_clean_env do
          system("/usr/sbin/td-agent --dry-run #{options_to_argv(config_file: file_path)}", out: File::NULL, err: File::NULL)
          raise ::Fluentd::Agent::ConfigError, last_error_message unless $?.exitstatus.zero?
        end
      end

      case FluentdUI.platform
      when :macosx
        include Macosx
      when :unix
        include Unix
      end
    end
  end
end
