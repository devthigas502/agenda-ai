# frozen_string_literal: true

class Professional < ApplicationRecord
  include Sortable

  acts_as_tenant :account

  # === Associations ===
  has_many :professional_services, dependent: :destroy
  has_many :services, through: :professional_services
  has_many :schedules, dependent: :destroy
  has_many :schedule_overrides, dependent: :destroy
  has_many :bookings, dependent: :restrict_with_error

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  # === Scopes ===
  scope :active, -> { where(active: true) }
end
