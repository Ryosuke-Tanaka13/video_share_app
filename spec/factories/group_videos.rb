FactoryBot.define do
  factory :group_video do
    association :group
    association :video
  end
end
