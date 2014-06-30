class GemUpdateCheck
  include SuckerPunch::Job
  workers 16

  def perform(gem_name)
    SuckerPunch.logger.info "check #{gem_name} latest version"
    pl = Plugin.new(gem_name: gem_name)
    pl.gem_versions!
  end
end
