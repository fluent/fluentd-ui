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
        exec_dryrun("/usr/sbin/td-agent", file_path)
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
