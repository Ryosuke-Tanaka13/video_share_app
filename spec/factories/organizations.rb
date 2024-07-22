FactoryBot.define do
  factory :organization, class: 'Organization' do
    id             { 1 }
    name           { 'セレブエンジニア' }
    email          { 'org_spec@example.com' }
    plan           { 1000 }
    customer_id    { 'cus_id_1' }
    subscription_id { 'sub_id_1' }
  end

  factory :another_organization, class: 'Organization' do
    id             { 2 }
    name           { 'テックリーダーズ' }
    email          { 'org_spec1@example.com' }
    plan           { 2000 }
    customer_id    { 'cus_id_2' }
    subscription_id { 'sub_id_2' }
  end

  factory :test_organization, class: 'Organization' do
    name           { 'セレブエンジニア' }
    email          { Faker::Internet.email }
  end
end
