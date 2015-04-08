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

      context 'when password != password_confirmation' do
        let(:current_password) { user.password }
        let(:password) { 'aaaaaaaa' }
        let(:password_confirmation) { 'bbbbbbbb' }

        it { should be_falsey }
      end
    end
  end
end
