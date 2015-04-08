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
          let(:password) { 'aaaaaaaa' }
          let(:password_confirmation) { password }

          it { should be_truthy }
        end

        context 'when password is 7 characters' do
          let(:password) { 'aaaaaaa' }
          let(:password_confirmation) { password }

          it { should be_falsey }
        end

        context 'when password != password_confirmation' do
          let(:password) { 'aaaaaaaa' }
          let(:password_confirmation) { 'bbbbbbbb' }

          it { should be_falsey }
        end
      end

      context 'when current_password is wrong' do
        let(:current_password) { 'invalid_password' }
        let(:password) { 'aaaaaaaa' }
        let(:password_confirmation) { password }

        it { should be_falsey }
      end
    end
  end
end
