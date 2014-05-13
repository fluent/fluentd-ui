describe "sessions" do
  let(:exists_user) { FactoryGirl.create(:user) }

  describe "the sign in process" do
    let(:submit_label) { I18n.t("terms.sign_in") }
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

  describe "sign out process" do
    let(:submit_label) { I18n.t("terms.sign_in") }
    before do
      visit '/sessions/new'
      within("form") do
        fill_in 'session_name', :with => exists_user.name
        fill_in 'session_password', :with => exists_user.password
      end
      click_button submit_label
    end

    before do
      visit root_path
      click_link I18n.t("terms.sign_out")
    end

    it "at sign in page after sign out" do
      current_path.should == new_sessions_path
    end

    it "remember_token was destroyed" do
      exists_user.reload
      exists_user.remember_token.should be_nil
    end
  end
end
