class Fluentd
  class Agent
    class TdAgent
      module Macosx

        def start
          backup_running_config do
            detached_command("launchctl load #{plist}") && pid_from_launchctl
          end
        end

        def stop
          detached_command("launchctl unload #{plist}") && FileUtils.rm(pid_file)
        end

        def restart
          stop && start
        end

        private

        def plist
          '/Library/LaunchDaemons/td-agent.plist'
        end

        def pid_from_launchctl
          # NOTE: launchctl doesn't make pidfile, so detect pid and store it to pidfile manually
          pid = `launchctl list | grep td-agent | cut -f1`.strip
          return if pid == ""
          File.open(pid_file, "w"){|f| f.write pid }
        end
      end
    end
  end
end
