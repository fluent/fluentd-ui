class GemInstallerJob < ApplicationJob
  queue_as :default

  def perform(gem_name, version = nil)
    SuckerPunch.logger.info "install #{gem_name} #{version}"
    pl = Plugin.new(gem_name: gem_name, version: version)
    begin
      # NOTE: uninstall all versions of `gem_name` then install it for upgrade/downgrade
      pl.uninstall! if pl.installed?
      pl.install!
      logger.info "installed #{gem_name} #{version}"
    rescue Plugin::GemError
      logger.warn "installing #{gem_name} #{version} is failed"
    end
  end
end
