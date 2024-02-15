FactoryBot.define do
  factory :viewer_group do
    association :viewer
    association :group
  end
end