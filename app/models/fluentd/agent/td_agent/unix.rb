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
          detached_command('/etc/init.d/td-agent restart')
        end
      end
    end
  end
end
