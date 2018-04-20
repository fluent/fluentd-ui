require "plugin" # Avoid: RuntimeError Circular dependency detected while autoloading constant Plugin
AllPluginCheckUpdateJob.perform_later
