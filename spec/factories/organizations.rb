FactoryBot.define do
  factory :organization, class: 'Organization' do
    name           { 'セレブエンジニア' }
    email          { Faker::Internet.email }
  end

  factory :another_organization, class: 'Organization' do
    name           { 'テックリーダーズ' }
    email          { Faker::Internet.email }
  end
end
