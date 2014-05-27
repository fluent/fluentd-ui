require 'spec_helper'

describe LoginToken do
  describe "#active, #inactive" do
    let(:active) { 3 }
    let(:inactive) { 5 }

    before do
      active.times do |n|
        create(:login_token, expired_at: (n + 1).day.from_now)
      end
      inactive.times do |n|
        create(:login_token, expired_at: (n + 1).day.ago)
      end
    end

    describe "#active" do
      subject { LoginToken.active }
      it { subject.count.should == active }
      it { subject.all?{|t| t.expired_at > Time.now}.should be_true }
    end

    describe "#inactive" do
      subject { LoginToken.inactive }
      it { subject.count.should == inactive }
      it { subject.all?{|t| t.expired_at <= Time.now}.should be_true }
    end
  end
end
