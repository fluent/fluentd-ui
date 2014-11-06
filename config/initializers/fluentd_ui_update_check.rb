unless FluentdUI.td_agent_ui?
  # td-agent-ui shouldn't auto update
  FluentdUiUpdateCheck.new.async.perform
end
