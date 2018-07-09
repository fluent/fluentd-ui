require "spec_helper"

describe "in_http", js: true, stub: :daemon do
  before { login_with exists_user }
  it_should_behave_like "configurable daemon settings", "in_http", "port", "12345"
end
