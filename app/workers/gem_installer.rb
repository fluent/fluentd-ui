class GemInstaller
  include SuckerPunch::Job
  workers 16

  def perform(gem_name, version = nil)
    SuckerPunch.logger.info "install #{gem_name} #{version}"
    pl = Plugin.new(gem_name: gem_name, version: version)
    pl.uninstall! if pl.installed?
    pl.install!
    SuckerPunch.logger.info "installed #{gem_name} #{version}"
  end
end
