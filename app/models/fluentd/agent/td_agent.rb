class Fluentd
  class Agent
    class TdAgent
      include Common

      def self.default_options
        {
          :pid_file => "/var/run/td-agent/td-agent.pid",
          :log_file => "/var/log/td-agent/td-agent.log",
          :config_file => "/etc/td-agent/td-agent.conf",
        }
      end

      def start
        system('/etc/init.d/td-agent start')
      end

      def stop
        system('/etc/init.d/td-agent stop')
      end

      def restart
        # NOTE: td-agent has no reload command
        # https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L156
        system('/etc/init.d/td-agent restart')
      end
    end
  end
end
