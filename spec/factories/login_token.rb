FactoryGirl.define do
  factory :login_token do
    user
    expired_at 1.year.from_now
  end
end
