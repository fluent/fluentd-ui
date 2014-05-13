require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }

  describe "#generate_remember_token" do
    subject { user.generate_remember_token }
    it { User.find_by(remember_token: subject).should be_nil }
  end

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

    describe "remember_token" do
      let(:token) { "xxx" }

      it "nil is valid" do
        user.remember_token = nil
        user.should be_valid
      end

      it "nil and taken is valid " do
        FactoryGirl.create(:user, remember_token: nil)
        user.remember_token = nil
        user.should be_valid
      end

      it "taken token is invalid" do
        FactoryGirl.create(:user, remember_token: token)
        user.remember_token = token
        user.should_not be_valid
      end
    end
  end
end
