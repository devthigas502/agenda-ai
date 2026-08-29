# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    account
    professional
    service
    client
    starts_at { 1.day.from_now.change(hour: 10, min: 0) }
    ends_at { 1.day.from_now.change(hour: 10, min: 30) }
    status { "pending" }
    price_cents { 5000 }
    source { "public_page" }
  end
end
