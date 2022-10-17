# frozen_string_literal: true

FactoryBot.define do
  factory :system_admin, class: 'SystemAdmin' do
    name                  { 'システム管理者' }
    email                 { 'admin_spec@example.com' }
    password              { 'password' }
    password_confirmation { 'password' }
  end
end
