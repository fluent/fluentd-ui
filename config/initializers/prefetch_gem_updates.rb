require "plugin" # Avoid: RuntimeError Circular dependency detected while autoloading constant Plugin
unless Rails.env.test?
  AllPluginCheckUpdateJob.perform_later
end
