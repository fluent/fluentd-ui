require 'spec_helper'

describe "sessions" do
  let(:exists_user) { build(:user) }
  let(:submit_label) { I18n.t("terms.sign_in") }
  let(:after_sign_in_location) { daemon_path }

  describe "sign in with default password" do
    before do
      login_with user
    end

    context "correct credentials" do
      let(:user) { exists_user }
      it "login success, then redirect to root_path, and redirect_to daemon_path from root_path" do
        current_path.should == after_sign_in_location
      end
    end

    context "wrong credentials" do
      let(:user) { build(:user, password: "passw0rd") }

      it "current location is not root_path" do
        current_path.should_not == after_sign_in_location
      end

      it "display form for retry" do
        page.body.should have_css('form')
      end
    end
  end

  describe "sign in with modified password" do
    let(:user) { build(:user, password: password) }
    let(:new_password) { "newpassword" }
    let(:old_password) { Settings.default_password }

    before do
      exists_user.update_attributes(current_password: Settings.default_password, password: new_password, password_confirmation: new_password)

      login_with user
    end

    after do
      # reset password to the default
      FileUtils.rm_f(User::ENCRYPTED_PASSWORD_FILE)
    end

    context "correct password" do
      let(:password) { new_password }
      it "login success" do
        current_path.should == after_sign_in_location
      end
    end

    context "wrong password" do
      let(:password) { old_password }
      it "login failed" do
        current_path.should_not == after_sign_in_location
      end
    end
  end

  describe "sign out process" do
    let(:submit_label) { I18n.t("terms.sign_in") }
    before do
      login_with exists_user
    end

    before do
      visit root_path
      click_link I18n.t("terms.sign_out")
    end

    it "at sign in page after sign out" do
      current_path.should == new_sessions_path
    end
  end
end
