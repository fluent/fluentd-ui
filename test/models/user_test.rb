require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build(:user)
  end

  sub_test_case "password" do
    def set_password(current_password, password, password_confirmation)
      @user.current_password = current_password
      @user.password = password
      @user.password_confirmation = password_confirmation
    end

    sub_test_case "when current password is correct" do
      test "password/confirmation is 8 characters" do
        set_password(@user.password, "a" * 8, "a" * 8)
        assert do
          @user.valid?
        end
      end

      test "password is 7 characters" do
        set_password(@user.password, "a" * 7, "a" * 7)
        assert do
          !@user.valid?
        end
        assert_equal([:password], @user.errors.keys)
      end

      test "password != password_confirmation" do
        set_password(@user.password, "a" * 8, "b" * 8)
        assert do
          !@user.valid?
        end
        assert_equal([:password], @user.errors.keys)
      end
    end

    test "current_password is wrong" do
      set_password("invalid_password", "a" * 8, "a" * 8)
      assert do
        !@user.valid?
      end
      assert_equal([:current_password], @user.errors.keys)
    end
  end
end
