class Fluentd
  class Agent
    module ProcessOperation
      def self.included(base)
        define_method(:dryrun!) do
          raise NotImplementedError, "'dryrun!' method is required to be defined"
        end
      end

      def running?
        begin
          pid && Process.kill(0, pid)
        rescue Errno::ESRCH
          File.unlink(pid_file) # no needed any more
          false
        end
      end

      def dryrun(file_path = nil)
        dryrun!(file_path)
        true
      rescue ::Fluentd::Agent::ConfigError
        false
      end

      def pid
        return unless File.exists?(pid_file)
        return if File.zero?(pid_file)
        File.read(pid_file).to_i rescue nil
      end

      private

      def exec_dryrun(command, file_path = nil)
        Bundler.with_clean_env do
          unless system("#{command} -q --dry-run #{options_to_argv(config_file: file_path)}", out: File::NULL, err: File::NULL)
            raise ::Fluentd::Agent::ConfigError, last_error_message
          end
        end
      end

      def detached_command(cmd)
        thread = Bundler.with_clean_env do
          pid = spawn(cmd)
          Process.detach(pid)
        end
        thread.join
        thread.value.exitstatus.zero?
      end

      def options_to_argv(opts = {})
        argv = ""
        argv << " --use-v1-config"
        argv << " -c #{opts[:config_file] || config_file}"
        argv << " -d #{opts[:pid_file] || pid_file}"
        argv << " -o #{opts[:log_file] || log_file}"
        argv
      end
    end
  end
end
