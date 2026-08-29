# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    account
    name { "Corte de Cabelo" }
    description { "Corte masculino completo" }
    duration_minutes { 30 }
    price_cents { 5000 }
    currency { "BRL" }
    active { true }
    sequence(:position) { |n| n }
  end
end
