# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    account
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { "owner" }
  end
end
