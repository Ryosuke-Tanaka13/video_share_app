# frozen_string_literal: true

FactoryBot.define do
  factory :system_admin, class: 'SystemAdmin' do
    id             { 1 }
    name           { 'システム管理者' }
    email          { 'test_system_admin_spec@example.com' }
    password       { 'password' }
  end
end
