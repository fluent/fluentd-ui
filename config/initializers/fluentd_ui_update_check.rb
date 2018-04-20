require "plugin" # Avoid: RuntimeError Circular dependency detected while autoloading constant Plugin
unless Rails.env.test?
  unless FluentdUI.td_agent_ui?
    # td-agent-ui shouldn't auto update
    FluentdUiUpdateCheckJob.perform_later
  end
end
