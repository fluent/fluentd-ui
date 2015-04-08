require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  describe "#valid?" do
    describe "password" do
      it "password != password_confirmation is invalid" do
        user.current_password = user.password
        user.password = "aaaaaaaa"
        user.password_confirmation = "bbbbbbbb"
        user.should_not be_valid
      end
    end
  end
end
