FactoryBot.define do
  factory :organization, class: 'Organization' do
    id             { 1 }
    name           { 'セレブエンジニア' }
    email          { 'org_spec@example.com' }
  end

  factory :another_organization, class: 'Organization' do
    id             { 2 }
    name           { 'テックリーダーズ' }
    email          { 'org_spec1@example.com' }
  end

  factory :deactivated_organization, class: 'Organization' do
    id             { 3 }
    name           { '非アクティブ組織' }
    email          { 'org_spec2@example.com' }
    is_valid       { false }
  end
end
