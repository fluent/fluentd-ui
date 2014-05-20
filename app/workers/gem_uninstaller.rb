class GemUninstaller
  include SuckerPunch::Job
  workers 16

  WORKING = []

  def perform(gem_name)
    SuckerPunch.logger.info "uninstall #{gem_name}"
    pl = Plugin.new(gem_name: gem_name)
    unless WORKING.find{|p| p.gem_name == pl.gem_name}
      WORKING.push(pl)
      begin
        pl.uninstall!
      ensure
        WORKING.delete(pl)
      end
    end
    SuckerPunch.logger.info "uninstalled #{gem_name}"
  end
end
