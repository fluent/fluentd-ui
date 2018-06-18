require "spec_helper"

describe "out_stdout", stub: :daemon do
  before { login_with exists_user }
  it_should_behave_like "configurable daemon settings", "out_stdout", "pattern", "stdout.**"

end
