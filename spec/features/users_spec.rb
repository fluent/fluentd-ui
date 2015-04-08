require "spec_helper"

describe "users" do
  describe "unlogined" do
    let(:url) { user_path }
    it_should_behave_like "login required"
  end

  describe "edit" do
  end
end
