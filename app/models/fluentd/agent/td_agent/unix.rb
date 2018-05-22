class Fluentd
  class Agent
    class TdAgent
      module Unix
        def start
          backup_running_config do
            detached_command("systemctl start td-agent.service")
          end
        end

        def stop
          detached_command("systemctl stop td-agent.service")
        end

        def restart
          detached_command("systemctl restart td-agent.service")
        end

        def reload
          detached_command("systemctl reload td-agent.service")
        end
      end
    end
  end
end
