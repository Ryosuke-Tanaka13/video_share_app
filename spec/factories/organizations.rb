FactoryBot.define do
  factory :organization, class: 'Organization' do
    id             { 1 }
    name           { 'セレブエンジニア' }
    email          { 'org1@example.com' }
  end

  factory :another_organization, class: 'Organization' do
    id             { 2 }
    name           { 'テックリーダーズ' }
    email          { 'org2@example.com' }
  end
end
