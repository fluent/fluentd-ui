class GemUninstaller
  include SuckerPunch::Job
  workers 16

  def perform(gem_name)
    SuckerPunch.logger.info "uninstall #{gem_name}"
    pl = Plugin.new(gem_name: gem_name)
    begin
      pl.uninstall!
      SuckerPunch.logger.info "uninstalled #{gem_name}"
    rescue Plugin::GemError
      SuckerPunch.logger.warn "uninstalling #{gem_name} is failed"
    end
  end
end
