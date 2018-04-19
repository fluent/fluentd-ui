class AllPluginCheckUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Plugin.installed.each do |pl|
      GemUpdateCheckJob.perform_later(pl.gem_name)
    end
    AllPluginCheckUpdateJob.set(wait: 1.hour).perform_later # will be checked every hour
  end
end
