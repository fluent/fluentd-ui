require 'spec_helper'

describe User do
  let(:user) { build(:user) }

  describe "#valid?" do
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

        it 'should be false' do
          user.should_not be_valid
        end
      end
    end
  end
end
