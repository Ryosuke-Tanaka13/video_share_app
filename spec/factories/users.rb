# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name)  { |n| "投稿者#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password         { 'password' }
    organization
  end
end
