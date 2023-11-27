FactoryBot.define do
  factory :organization, class: 'Organization' do
    name           { 'セレブエンジニア' }
    email          { 'org_spec@example.com' }
  end

  factory :another_organization, class: 'Organization' do
    name           { 'テックリーダーズ' }
    email          { 'org_spec1@example.com' }
  end
end
