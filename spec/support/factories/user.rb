# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: '::User' do
    sequence(:name)  { |n| "Name-#{n}" }
    sequence(:email) { |n| "user-#{n}@email.com" }
    sequence(:password) { |n| SecureRandom.hex(10) }
  end
end
