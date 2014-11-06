require "spec_helper"

describe "users" do
  describe "edit" do
    let(:url) { user_path }
    it_should_behave_like "login required"
  end

end
