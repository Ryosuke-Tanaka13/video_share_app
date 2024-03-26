FactoryBot.define do
  factory :organization, class: 'Organization' do
    name           { 'セレブエンジニア' }
    email          { Faker::Internet.unique.email }
  end

  factory :another_organization, class: 'Organization' do
    name           { 'テックリーダーズ' }
    email          { Faker::Internet.unique.email }
  end

  factory :test_organization, class: 'Organization' do
    name           { 'テスト' }
    email          { Faker::Internet.unique.email }
  end
end