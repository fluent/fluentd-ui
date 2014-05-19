class GemInstaller
  include SuckerPunch::Job
  workers 16

  WORKING = []

  def perform(gem_name, version = nil)
    SuckerPunch.logger.info "install #{gem_name} #{version}"
    pl = Plugin.new(gem_name: gem_name, version: version)
    unless WORKING.find{|p| p.gem_name == pl.gem_name}
      WORKING.push(pl)
      pl.uninstall! if pl.installed?
      pl.install!
      WORKING.delete(pl)
    end
    SuckerPunch.logger.info "installed #{gem_name} #{version}"
  end
end
