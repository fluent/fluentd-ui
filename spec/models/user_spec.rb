require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }

  describe "#valid?" do
    it { user.should be_valid }

    describe "name" do
      it "nil is invalid" do
        user.name = nil
        user.should_not be_valid
      end

      it "taken name is invalid" do
        another_user = FactoryGirl.create(:user)
        user.name = another_user.name
        user.should_not be_valid
      end
    end

    describe "password" do
      it "password != password_confirmation is invalid" do
        user.password = "a"
        user.password_confirmation = "b"
        user.should_not be_valid
      end
    end
  end
end
