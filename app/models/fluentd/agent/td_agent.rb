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

      def start
        detached_command('/etc/init.d/td-agent start')
      end

      def stop
        detached_command('/etc/init.d/td-agent stop')
      end

      def restart
        # NOTE: td-agent has no reload command
        # https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L156
        detached_command('/etc/init.d/td-agent restart')
      end

      def version
        `/usr/sbin/td-agent --version`.strip
      end

      private

      def detached_command(cmd)
        Bundler.with_clean_env do
          pid = spawn(cmd)
          Process.detach(pid)
        end
        sleep 1 # NOTE/FIXME: too early return will be caused incorrect status report, "sleep 1" is a adhoc hack
      end
    end
  end
end
