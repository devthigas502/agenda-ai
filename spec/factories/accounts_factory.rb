# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    name { Faker::Company.name }
    sequence(:slug) { |n| "negocio-#{n}" }
    email { Faker::Internet.email }
    phone { "(11) 9#{Faker::Number.number(digits: 8)}" }
    timezone { "America/Sao_Paulo" }
    plan { "trial" }
  end
end
