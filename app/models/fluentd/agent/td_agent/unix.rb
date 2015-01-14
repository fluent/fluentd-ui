class Fluentd
  class Agent
    class TdAgent
      module Unix
        def start
          backup_running_config do
            detached_command('/etc/init.d/td-agent start')
          end
        end

        def stop
          detached_command('/etc/init.d/td-agent stop')
        end

        def restart
          # NOTE: td-agent has no reload command
          # https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L156
          detached_command('/etc/init.d/td-agent restart')
        end

        def dryrun
          detached_command('/etc/init.d/td-agent configtest')
        end
      end
    end
  end
end
