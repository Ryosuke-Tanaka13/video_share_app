# frozen_string_literal: true

FactoryBot.define do
  factory :user_owner, class: 'User' do
    name           { 'owner' }
    email          { 'test_spec@example.com' }
    password         { 'password' }
    organization_id { 1 }
    role           { 1 }
  end

  factory :another_user_owner, class: 'User' do
    name           { 'owner1' }
    email          { 'test_spec1@example.com' }
    password         { 'password' }
    organization_id { 2 }
    role           { 1 }
  end

  factory :user, class: 'User' do
    name           { 'user' }
    email          { 'test_spec2@example.com' }
    password         { 'password' }
    organization_id { 1 }
    role { 0 }
  end

  factory :user1, class: 'User' do
    name           { 'user1' }
    email          { 'test_spec3@example.com' }
    password         { 'password' }
    organization_id { 1 }
    role { 0 }
  end

  factory :another_user, class: 'User' do
    name           { 'user2' }
    email          { 'test_spec4@example.com' }
    password         { 'password' }
    organization_id { 2 }
    role { 0 }
  end
end
