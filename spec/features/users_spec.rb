describe "users" do
  let(:exists_user) { FactoryGirl.create(:user) }

  describe "edit" do
    let(:url) { user_path }
    it_should_behave_like "login required"
  end

end
