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

      def pid
        return unless File.exists?(pid_file)
        File.read(pid_file).to_i rescue nil
      end

      def wait_process_starting_seconds
        10.seconds # wait time for fluentd pidfile created
      end

      def running?
        begin
          pid && Process.kill(0, pid)
        rescue Errno::ESRCH
          File.unlink(pid_file) # no needed any more
          false
        end
      end

      def log
        File.read(log_file) # TODO: large log file
      end

      def recent_errors(limit = 3)
        return [] unless File.exist?(log_file)
        errors = []
        buf = []
        io = File.open(log_file)
        reader = ::FileReverseReader.new(io)
        reader.each_line do |line|
          break if errors.length >= limit
          unless line["error"]
            if buf.present?
              errors << buf.reverse
            end
            buf = []
            next
          end
          buf << line
        end
        errors
      ensure
        io && io.close
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

      %w(start stop restart).each do |method|
        define_method(method) do
          raise NotImplementedError
        end
      end
    end
  end
end
