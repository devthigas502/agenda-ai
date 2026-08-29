# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    account
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { "(11) 9#{Faker::Number.number(digits: 8)}" }
  end
end
