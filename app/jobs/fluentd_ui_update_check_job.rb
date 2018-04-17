class FluentdUiUpdateCheckJob < ApplicationJob
  queue_as :default

  def perform
    pl = Plugin.new(gem_name: "fluentd-ui")
    if pl.gem_versions
      FluentdUI.latest_version = pl.latest_version
    end
    # sucker_punch adapter does not implement enqueue_at
    # FluentdUiUpdateCheckJob.set(wait: 1.hour).perfom_later # will be checked every hour
  end
end
