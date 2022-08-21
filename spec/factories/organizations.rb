FactoryBot.define do
  factory :organization do
    sequence(:name)  { |n| "組織#{n}" }
    sequence(:email) { |n| "org#{n}@example.com" }
  end
end
