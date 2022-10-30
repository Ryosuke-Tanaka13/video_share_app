# frozen_string_literal: true

FactoryBot.define do
  factory :user_owner, class: 'User' do
    id               { 1 }
    name             { 'オーナー' }
    email            { 'owner_spec@example.com' }
    password         { 'password' }
    organization_id  { 1 }
    role             { 'owner' }
  end

  factory :another_user_owner, class: 'User' do
    id               { 2 }
    name             { 'オーナー1' }
    email            { 'owner_spec1@example.com' }
    password         { 'password' }
    organization_id  { 2 }
    role             { 'owner' }
  end

  factory :user_staff, class: 'User' do
    id               { 3 }
    name             { 'スタッフ' }
    email            { 'staff_spec@example.com' }
    password         { 'password' }
    organization_id  { 1 }
    role             { 'staff' }
  end

  factory :user_staff1, class: 'User' do
    id               { 4 }
    name             { 'スタッフ1' }
    email            { 'staff_spec1@example.com' }
    password         { 'password' }
    organization_id  { 1 }
    role             { 'staff' }
  end

  factory :another_user_staff, class: 'User' do
    id               { 5 }
    name             { 'スタッフ2' }
    email            { 'staff_spec2@example.com' }
    password         { 'password' }
    organization_id  { 2 }
    role             { 'staff' }
  end

  factory :user, class: 'User' do
    id               { 6 }
    name             { 'ユーザー' }
    email            { 'user_sprec1@example.com' }
    password         { 'password' }
    organization_id  { 1 }
    role             { 'staff' }
  end
end
