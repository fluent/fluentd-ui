class FluentdUiUpdateCheck
  include SuckerPunch::Job

  def perform
    pl = Plugin.new(gem_name: "fluentd-ui")
    if pl.gem_versions # NOTE: fluentd-ui is not released yet, so `pl.latest_version` will fail for now
      FluentdUI.latest_version = pl.latest_version
    end
    later(3600) # will be checked every hour
  end

  def later(sec)
    after(sec) { perform }
  end
end
