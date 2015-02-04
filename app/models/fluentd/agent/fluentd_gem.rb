class Fluentd
  class Agent
    class FluentdGem
      include Common
      include LocalCommon

      def self.default_options
        {
          :pid_file    => "#{ENV["HOME"]}/.fluentd-ui/fluent.pid",
          :log_file    => "#{ENV["HOME"]}/.fluentd-ui/fluent.log",
          :config_file => "#{ENV["HOME"]}/.fluentd-ui/fluent.conf",
        }
      end

      # return value is status_after_this_method_called == started
      def start
        return true if running?

        backup_running_config do
          actual_start
        end
      end

      # return value is status_after_this_method_called == stopped
      def stop
        return true unless running?
        actual_stop
      end

      # return value is status_after_this_method_called == started
      def restart
        if running?
          validate_fluentd_options && stop && start
        else
          # NOTE: no path to here from browser operations for now
          start
        end
      end

      def reload # NOTE: does not used currently, and td-agent has no reload command
        return false unless running?
        actual_reload
      end

      def dryrun!(file_path = nil)
        exec_dryrun("fluentd", file_path)
      end

      def config_syntax_check
        Fluent::Config::V1Parser.parse(params[:config], config_file)
        true
      rescue Fluent::ConfigParseError
        false
      end

      def version
        Bundler.with_clean_env do
          `fluentd --version`.strip
        end
      end

      private

      def validate_fluentd_options
        dryrun
      end

      def actual_start
        return unless validate_fluentd_options
        Bundler.with_clean_env do
          spawn("fluentd #{options_to_argv}")
        end

        wait_starting
      end

      def actual_stop
        if Process.kill(:TERM, pid)
          File.unlink(pid_file)
          true
        end
      end

      def actual_reload
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
        rescue Errno::ESRCH
          # successful to create pidfile, but process not exists.
          # any error occured at booting process that after create pidfile. such as readling config, loading plugins, etc
          # https://github.com/fluent/fluentd/blob/master/lib/fluent/supervisor.rb#L106
          false
        rescue TimeoutError
          false
        end
      end
    end
  end
end
