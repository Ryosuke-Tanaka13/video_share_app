# frozen_string_literal: true

FactoryBot.define do
  factory :system_admin do
    sequence(:email) { |n| "system_admin#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
