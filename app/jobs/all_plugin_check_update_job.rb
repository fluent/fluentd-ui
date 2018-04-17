class AllPluginCheckUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Plugin.installed.each do |pl|
      GemUpdateCheckJob.perform_later(pl.gem_name)
    end
    # sucker_punch adapter does not implement enqueue_at
    # AllPluginCheckUpdateJob.set(wait: 1.hour).perform_later # will be checked every hour
  end
end
