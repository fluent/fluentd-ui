require 'fluent/log'
require 'fluent/env'
require 'fluent/version'
require 'fluent/supervisor'

class Fluentd
  class Agent
    class Base
      attr_reader :extra_options

      def initialize(options = {})
        @extra_options = options
      end

      def pid
        return unless File.exists?(pid_file)
        File.read(pid_file)
      end

      def running?
        pid && system("/bin/kill -0 #{pid}", :out => File::NULL, :err => File::NULL)
      end

      def log
        File.read(log_file) # TODO
      end

      %w(pid_file log_file config_file start stop reload).each do |method|
        define_method(method) do
          raise NotImplementedError
        end
      end

      # pidfile
      #   td-agent: /var/run/td-agent/td-agent.pid
      #   - https://github.com/treasure-data/td-agent/blob/master/td-agent.logrotate#L10
      #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L25
      #   fluentd:  nothing (or --daemon PIDFILE)
      #
      # logfile
      #   td-agent: /var/log/td-agent/td-agent.log
      #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L28
      #   fluentd: stdout (or --log LOGFILE)
      #
      # config file
      #   td-agent: /etc/td-agent/td-agent.conf
      #   - https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.postinst#L69
      #   fluentd: /etc/fluent/fluent.conf (by fluentd -s)
    end

    class Fluentd < Base
      def pid_file
        extra_options[:pid_file] || "/var/run/fluent.pid"
      end

      def log_file
        extra_options[:log_file] || "/var/log/fluent.log"
      end

      def config_file
        extra_options[:config_file] || "/etc/fluent/fluent.conf"
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
        return if running?
        spawn("bundle exec fluentd #{options_to_argv}") # TODO
      end

      def stop
        return unless running?
        system("/bin/kill -TERM #{pid}")
        File.unlink(pid_file)
      end

      def reload
        return unless running?
        system("/bin/kill -HUP #{pid}")
      end
    end

    class TdAgent < Base
      def pid_file
        "/var/run/td-agent/td-agent.pid"
      end

      def log_file
        "/var/log/td-agent/td-agent.log"
      end

      def config_file
        "/etc/td-agent/td-agent.conf"
      end

      def start
        system('/etc/init.d/td-agent start')
      end

      def stop
        system('/etc/init.d/td-agent stop')
      end

      def reload
        # NOTE: td-agent has no reload command
        # https://github.com/treasure-data/td-agent/blob/master/debian/td-agent.init#L156
        system('/etc/init.d/td-agent restart')
      end
    end

    class Remote < Base # TODO
    end
  end
end
