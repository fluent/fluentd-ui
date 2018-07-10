require "spec_helper"

describe "in_monitor_agent", js: true, stub: :daemon do
  before { login_with exists_user }
  it_should_behave_like "configurable daemon settings", "in_monitor_agent", "port", "12345"
end
