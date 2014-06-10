class AllPluginCheckUpdate
  include SuckerPunch::Job

  def perform
    Plugin.installed.each do |pl|
      GemUpdateCheck.new.async.perform(pl.gem_name)
    end
    later(3600) # will be checked every hour
  end

  def later(sec)
    after(sec) { perform }
  end
end
