require "test_helper"

class SessionsTest < ActionDispatch::IntegrationTest
  sub_test_case "sign in with default password" do
    test "correct credentials" do
      login_with(FactoryBot.build(:user))
      assert_equal(daemon_path, current_path)
    end

    test "wrond credentials" do
      login_with(FactoryBot.build(:user, password: "wrongpassword"))
      assert do
        daemon_path != current_path
      end
      assert do
        page.has_css?("form")
      end
    end
  end

  sub_test_case "sign in with modified password" do
    setup do
      new_password = "newpassword"
      @user = FactoryBot.build(:user)
      @user.update_attributes(current_password: Settings.default_password,
                              password: new_password,
                              password_confirmation: new_password)


    end

    teardown do
      # reset password to the default
      FileUtils.rm_f(User::ENCRYPTED_PASSWORD_FILE)
    end

    test "login success with correct password" do
      login_with(@user)
      assert_equal(daemon_path, current_path)
    end

    test "login failure with wrong password" do
      login_with(@user, password: "wrongpassword")
      assert do
        daemon_path != current_path
      end
    end
  end

  test "at sign in page after sign out" do
    login_with(FactoryBot.build(:user))
    visit(root_path)
    click_link(I18n.t("terms.sign_out"))
    assert_equal(new_sessions_path, current_path)
  end
end
