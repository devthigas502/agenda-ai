# frozen_string_literal: true

class Client < ApplicationRecord
  acts_as_tenant :account

  # === Associations ===
  has_many :bookings, dependent: :restrict_with_error

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone, presence: true

  # === Scopes ===
  scope :search, ->(query) {
    where("name ILIKE :q OR email ILIKE :q OR phone ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  # Find or create a client by phone within the current tenant
  def self.find_or_initialize_by_phone(phone, attributes = {})
    find_or_initialize_by(phone: phone).tap do |client|
      client.assign_attributes(attributes) if client.new_record?
    end
  end
end
