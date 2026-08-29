# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    professional
    weekday { 1 } # Monday
    starts_at { Time.parse("08:00") }
    ends_at { Time.parse("18:00") }
  end
end
