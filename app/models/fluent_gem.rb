module FluentGem
  class GemError < StandardError; end

  class << self
    def install(*args)
      run("install", *args)
    end

    def uninstall(*args)
      run("uninstall", *args)
    end

    def list
      output = `#{gem} list`
      unless $?.exitstatus.zero?
        raise GemError, "failed command `#{gem} list`"
      end
      output.lines
    end

    def run(*args)
      # NOTE: use `fluent-gem` instead of `gem`
      Bundler.with_clean_env do
        # NOTE: this app is under the Bundler, so call `system` in with_clean_env is Bundler jail breaking
        cmd = [gem, *args].compact
        unless system(*cmd)
          raise GemError, "failed command: `#{cmd.join(" ")}`"
        end
      end
      true
    end

    def gem
      # Not yet setup any fluentd/td-agent
      return "fluent-gem" unless Fluentd.instance

      # On installed both td-agent and fluentd system, decide which fluent-gem command should be used depend on setup(Fluentd.instance)
      if Fluentd.instance && Fluentd.instance.fluentd?
        return "fluent-gem" # maybe `fluent-gem` command is in the $PATH
      else
        detect_td_agent_gem
      end
    end

    def detect_td_agent_gem
      # NOTE: td-agent has a command under the /usr/lib{,64}, td-agent2 has under /opt/td-agent
      %W(
        /usr/sbin/td-agent-gem
        /opt/td-agent/embedded/bin/fluent-gem
        /usr/lib/fluent/ruby/bin/fluent-gem
        /usr/lib64/fluent/ruby/bin/fluent-gem
        fluent-gem
      ).find do |path|
        system("which #{path}", out: File::NULL, err: File::NULL)
      end
    end
  end
end
