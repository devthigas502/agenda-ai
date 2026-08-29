# frozen_string_literal: true

class Service < ApplicationRecord
  include Sortable

  acts_as_tenant :account

  # === Associations ===
  has_many :professional_services, dependent: :destroy
  has_many :professionals, through: :professional_services
  has_many :bookings, dependent: :restrict_with_error

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :duration_minutes, presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 480 }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  # === Scopes ===
  scope :active, -> { where(active: true) }

  # === Instance Methods ===
  def price_in_reais
    price_cents / 100.0
  end

  def price_reais
    price_in_reais
  end

  def price_reais=(value)
    self.price_cents = (value.to_f * 100).round if value.present?
  end

  def formatted_price
    ActionController::Base.helpers.number_to_currency(price_in_reais, unit: "R$", separator: ",", delimiter: ".")
  end

  def formatted_duration
    hours = duration_minutes / 60
    minutes = duration_minutes % 60
    if hours > 0 && minutes > 0
      "#{hours}h#{minutes}min"
    elsif hours > 0
      "#{hours}h"
    else
      "#{minutes}min"
    end
  end
end
