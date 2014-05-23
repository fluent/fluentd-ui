class Fluentd
  class Agent
    class Fluentd
      include Common

      def self.default_options
        {
          :pid_file => "/var/run/fluent.pid",
          :log_file => "/var/log/fluent.log",
          :config_file => "/etc/fluent/fluent.conf",
        }
      end

      def options_to_argv
        argv = ""
        argv << " --use-v1-config"
        argv << " -c #{config_file}"
        argv << " -d #{pid_file}"
        argv << " -o #{log_file}"
        argv
      end

      def start
        return true if running?
        if validate_fluentd_options
          actual_start
        end
      end

      def stop
        return true unless running?
        actual_stop
      end

      def restart
        return false unless running?
        actual_restart
      end

      private

      def validate_fluentd_options
        system("bundle exec fluentd --dry-run #{options_to_argv}")
      end

      def actual_start
        spawn("bundle exec fluentd #{options_to_argv}")
        wait_starting
      end

      def actual_stop
        if Process.kill(:TERM, pid)
          File.unlink(pid_file)
          true
        end
      end

      def actual_restart
        Process.kill(:HUP, pid)
      end

      def wait_starting
        begin
          timeout(wait_process_starting_seconds) do
            loop do
              break if pid && Process.kill(0, pid)
              sleep 0.01
            end
          end
          true
        rescue TimeoutError
          false
        end
      end
    end
  end
end
