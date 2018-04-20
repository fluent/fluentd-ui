class GemUpdateCheckJob < ApplicationJob
  queue_as :default

  def perform(gem_name)
    logger.info "check #{gem_name} latest version"
    pl = Plugin.new(gem_name: gem_name)
    pl.gem_versions!
  end
end
