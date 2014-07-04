class FluentdUiRestart
  include SuckerPunch::Job

  LOCK = []

  def lock!
    raise "update process is still running" if LOCK.present?
    LOCK << true
  end

  def unlock!
    LOCK.shift
  end

  def perform
    lock!
    sleep 5 # delay for render updating HTML

    # NOTE: install will be failed before released fluentd-ui gem
    SuckerPunch.logger.info "[restart] install new fluentd-ui"
    Plugin.new(gem_name: "fluentd-ui").install!

    if Rails.env.production?
      cmd = %W(#{Rails.root}/bin/fluentd-ui start)
    else
      cmd = %W(bundle exec rails s)
    end

    SuckerPunch.logger.info "[restart] will restart"
    Bundler.with_clean_env do
      restarter = "#{Rails.root}/bin/fluentd-ui-restart"
      Process.spawn(*[restarter, $$.to_s, *cmd, *ARGV]) && Process.kill(:TERM, $$)
    end
  ensure
    # don't reach here if restart is successful
    unlock!
  end
end
