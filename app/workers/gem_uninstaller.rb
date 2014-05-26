class GemUninstaller
  include SuckerPunch::Job
  workers 16

  def perform(gem_name)
    SuckerPunch.logger.info "uninstall #{gem_name}"
    pl = Plugin.new(gem_name: gem_name)
    data = { plugin: pl, type: :uninstall, state: :running }
    if Plugin::WORKING.grep(data).blank?
      Plugin::WORKING.push(data)
      begin
        pl.uninstall!
      ensure
        Plugin::WORKING.delete(data)
      end
    end
    SuckerPunch.logger.info "uninstalled #{gem_name}"
  end
end
