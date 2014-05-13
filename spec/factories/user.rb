FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "user#{n}" }
    password "passw0rd"
    password_confirmation "passw0rd"
  end
end
