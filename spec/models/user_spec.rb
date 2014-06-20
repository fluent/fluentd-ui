require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  describe "#valid?" do
    describe "password" do
      it "password != password_confirmation is invalid" do
        user.password = "a"
        user.password_confirmation = "b"
        user.should_not be_valid
      end
    end
  end
end
