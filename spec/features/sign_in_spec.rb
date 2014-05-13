describe "the sign in process" do
  let(:submit_label) { I18n.t("terms.sign_in") }
  let(:exists_user) { FactoryGirl.create(:user) }
  before do
    visit '/sessions/new'
    within("form") do
      fill_in 'session_name', :with => user.name
      fill_in 'session_password', :with => user.password
    end
    click_button submit_label
  end

  context "sign in with exists user" do
    let(:user) { exists_user }
    it "login success, then redirect to root_path" do
      current_path.should == root_path
    end
  end

  context "sign in with non-exists user" do
    let(:user) { FactoryGirl.build(:user) }

    it "current location is not root_path" do
      current_path.should_not == root_path
    end

    it "display form for retry" do
      page.body.should have_css('form')
    end
  end
end
