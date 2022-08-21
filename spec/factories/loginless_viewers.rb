FactoryBot.define do
  factory :loginless_viewer do
    sequence(:name)  { |n| "レス視聴者#{n}" }
    sequence(:email) { |n| "less#{n}@example.com" }
  end
end
