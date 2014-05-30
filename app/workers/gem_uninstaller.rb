class GemUninstaller
  include SuckerPunch::Job
  workers 16

  def perform(gem_name)
    SuckerPunch.logger.info "uninstall #{gem_name}"
    pl = Plugin.new(gem_name: gem_name)
    pl.uninstall!
    SuckerPunch.logger.info "uninstalled #{gem_name}"
  end
end
