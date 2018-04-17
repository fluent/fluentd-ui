class GemUninstallerJob < ApplicationJob
  queue_as :default

  def perform(gem_name)
    logger.info "uninstall #{gem_name}"
    pl = Plugin.new(gem_name: gem_name)
    begin
      pl.uninstall!
      logger.info "uninstalled #{gem_name}"
    rescue Plugin::GemError
      logger.warn "uninstalling #{gem_name} is failed"
    end
  end
end
