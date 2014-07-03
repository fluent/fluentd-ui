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

class Fluentd
  class Agent
    module Common
      attr_reader :extra_options

      def initialize(options = {})
        @extra_options = options
      end

      def wait_process_starting_seconds
        10.seconds # wait time for fluentd pidfile created
      end

      def errors_since(since = 1.day.ago)
        errors = []
        logged_errors do |error|
          break if Time.parse(error[:subject]) < since
          errors << error
        end
        errors
      end

      def recent_errors(limit = 3)
        errors = []
        logged_errors do |error|
          errors << error
          break if errors.length >= limit
        end
        errors
      end

      def pid_file
        extra_options[:pid_file] || self.class.default_options[:pid_file]
      end

      def log_file
        extra_options[:log_file] || self.class.default_options[:log_file]
      end

      def config_file
        extra_options[:config_file] || self.class.default_options[:config_file]
      end


      # define these methods on each Agent class

      %w(start stop restart).each do |method|
        define_method(method) do
          raise NotImplementedError, "'#{method}' method is required to be defined"
        end
      end

      %w(running? log config config_write config_append log_tail configuration).each do |method|
        define_method(method) do
          raise NotImplementedError, "'#{method}' method is required to be defined"
        end
      end
    end
  end
end
