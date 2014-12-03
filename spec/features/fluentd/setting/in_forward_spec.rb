require "spec_helper"

describe "in_forward", stub: :daemon do
  before { login_with exists_user }
  it_should_behave_like "configurable daemon settings", "in_forward", "port", "12345"

end
