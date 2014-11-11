class Fluentd
  class Agent
    class TdAgent
      module Macosx

        def start
          detached_command("launchctl load #{plist}")
        end

        def stop
          detached_command("launchctl unload #{plist}")
        end

        def restart
          stop && start
        end

        private

        def plist
          '/Library/LaunchDaemons/td-agent.plist'
        end
      end
    end
  end
end
