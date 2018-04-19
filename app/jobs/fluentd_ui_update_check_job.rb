class FluentdUiUpdateCheckJob < ApplicationJob
  queue_as :default

  def perform
    pl = Plugin.new(gem_name: "fluentd-ui")
    if pl.gem_versions
      FluentdUI.latest_version = pl.latest_version
    end
    FluentdUiUpdateCheckJob.set(wait: 1.hour).perform_later # will be checked every hour
  end
end
