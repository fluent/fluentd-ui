class AllPluginCheckUpdateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Plugin.installed.each do |pl|
      GemUpdateCheckJob.perform_later(pl.gem_name)
    end
    later(3600) # will be checked every hour
  end
end
