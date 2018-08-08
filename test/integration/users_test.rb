require "test_helper"

class UsersTest < ActionDispatch::IntegrationTest
  test "login required" do
    login_required(user_path)
  end

  sub_test_case "edit" do
    setup do
      @user = FactoryBot.build(:user)
      login_with(@user)
    end

    teardown do
      # reset password to the default
      FileUtils.rm_f(User::ENCRYPTED_PASSWORD_FILE)
    end

    sub_test_case "to change password" do
      def update_password(current_password, password, password_confirmation)
        visit user_path
        fill_in 'user[current_password]', with: current_password

        fill_in 'user[password]', with: password
        fill_in 'user[password_confirmation]', with: password_confirmation
        click_button I18n.t("terms.update_password")
      end

      test "when input valid new password/confirmation" do
        update_password(@user.password, "newpassword", "newpassword")
        page.has_css?(".alert-success")
        assert_equal(@user.digest("newpassword"), @user.stored_digest)
      end

      test "when input invalid new password/confirmation" do
        original_digest = @user.stored_digest
        update_password(@user.password, "newpassword", "invalidpassword")
        page.has_css?(".alert-danger")
        assert_equal(original_digest, @user.stored_digest)
      end
    end
  end
end
