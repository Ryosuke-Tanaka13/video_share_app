# frozen_string_literal: true

FactoryBot.define do
  factory :viewer do
    sequence(:name)  { |n| "NAME#{n}" }
    sequence(:email) { |n| "TEST#{n}@example.com" }
    password         { 'password' }
  end

  factory :another_viewer, class: 'Viewer' do
    id { 2 }
    name { '別の動画視聴者' }
    email { 'another_viewer@example.com' }
    password { 'password' }
  end
end
