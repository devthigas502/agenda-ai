# frozen_string_literal: true

class ProfessionalService < ApplicationRecord
  belongs_to :professional
  belongs_to :service

  validates :professional_id, uniqueness: { scope: :service_id }

  # Returns the effective duration, falling back to the service default
  def effective_duration_minutes
    custom_duration_minutes || service.duration_minutes
  end

  # Returns the effective price, falling back to the service default
  def effective_price_cents
    custom_price_cents || service.price_cents
  end
end
