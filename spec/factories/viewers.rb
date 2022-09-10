# frozen_string_literal: true

FactoryBot.define do
  factory :viewer do
    sequence(:name)  { |n| "NAME#{n}" }
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password         { 'password' }
  end
end
