require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  describe "#valid?" do
    subject { user.valid? }

    describe "password" do
      before do
        user.current_password = current_password
        user.password = password
        user.password_confirmation = password_confirmation
      end

      context 'when current_password is correct' do
        let(:current_password) { user.password }

        context 'when password/confirmation is 8 characters' do
          let(:password) { 'a' * 8 }
          let(:password_confirmation) { password }

          it { should be_truthy }
        end

        context 'when password is 7 characters' do
          let(:password) { 'a' * 7 }
          let(:password_confirmation) { password }

          it 'should return false' do
            should be_falsey
            user.errors.keys.should == [:password]
          end
        end

        context 'when password != password_confirmation' do
          let(:password) { 'a' * 8 }
          let(:password_confirmation) { 'b' * 8 }

          it 'should return false' do
            should be_falsey
            user.errors.keys.should == [:password]
          end
        end
      end

      context 'when current_password is wrong' do
        let(:current_password) { 'invalid_password' }
        let(:password) { 'a' * 8 }
        let(:password_confirmation) { password }

        it 'should return false' do
          should be_falsey
          user.errors.keys.should == [:current_password]
        end
      end
    end
  end
end
