module FluentGem
  class GemError < StandardError; end

  class << self
    LIST_CACHE_KEY = "gem_list".freeze

    def install(*args)
      run("install", *args)
    end

    def uninstall(*args)
      run("uninstall", *args)
    end

    def list
      # NOTE: gem list is heavyly used from anywhere in 1 request, if not caching, user experience to be bad
      #       but long living caching causes mismatch with actual status e.g. user install plugin from console (without fluentd-ui)
      #       So our decision is that cache `gem list` in 3 seconds
      Rails.cache.fetch(LIST_CACHE_KEY, expires_in: 3.seconds) do
        output = `#{gem} list 2>&1`
        if $? && $?.exitstatus != 0 # NOTE: $? will be nil on CircleCI, so check $? at first
          raise GemError, "failed command: `#{gem} list` output: #{output}"
        end
        output.lines.to_a
      end
    end

    def run(*args)
      # NOTE: use `fluent-gem` instead of `gem`
      Bundler.with_clean_env do
        # NOTE: this app is under the Bundler, so call `system` in with_clean_env is Bundler jail breaking
        cmd = [gem, *args].compact
        unless system(*cmd)
          raise GemError, "failed command: `#{cmd.join(" ")}`"
        end
        Rails.cache.delete(LIST_CACHE_KEY)
      end
      true
    end

    def gem
      # Not yet setup any fluentd/td-agent
      return "fluent-gem" unless Fluentd.instance

      # On installed both td-agent and fluentd system, decide which fluent-gem command should be used depend on setup(Fluentd.instance)
      if Fluentd.instance && Fluentd.instance.fluentd?
        "fluent-gem" # maybe `fluent-gem` command is in the $PATH
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
