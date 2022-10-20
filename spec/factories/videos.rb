FactoryBot.define do
  factory :video do
    association :user
    association :organization
    id { 1 }
    video { 'video' }
    title { 'TestVideo' }
  end
end
