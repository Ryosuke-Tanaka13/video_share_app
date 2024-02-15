FactoryBot.define do
  factory :group do
    name { 'MyString' }
    association :organization
  end
end
