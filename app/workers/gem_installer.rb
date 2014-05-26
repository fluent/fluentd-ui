class GemInstaller
  include SuckerPunch::Job
  workers 16

  def perform(gem_name, version = nil)
    SuckerPunch.logger.info "install #{gem_name} #{version}"
    pl = Plugin.new(gem_name: gem_name, version: version)
    data = { plugin: pl, type: :install, state: :running }
    if Plugin::WORKING.grep(data).blank?
      Plugin::WORKING.push(data)
      begin
        pl.uninstall! if pl.installed?
        pl.install!
      ensure
        Plugin::WORKING.delete(data)
      end
    end
    SuckerPunch.logger.info "installed #{gem_name} #{version}"
  end
end
