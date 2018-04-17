class FluentdUiUpdateCheckJob < ApplicationJob
  queue_as :default

  def perform
    pl = Plugin.new(gem_name: "fluentd-ui")
    if pl.gem_versions
      FluentdUI.latest_version = pl.latest_version
    end
    later(3600) # will be checked every hour
  end
end
