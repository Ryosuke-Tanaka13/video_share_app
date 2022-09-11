# frozen_string_literal: true

FactoryBot.define do
  factory :viewer, class: 'Viewer' do
    name     { 'viewer' }
    email    { 'test@example.com' }
    password { 'password' }
  end

  factory :viewer1, class: 'Viewer' do
    name     { 'viewer1' }
    email    { 'test1@example.com' }
    password { 'password' }
  end
end
