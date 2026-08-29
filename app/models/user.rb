# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :account

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  # API Authentication Token
  has_secure_token :api_token

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :role, presence: true, inclusion: { in: %w[owner admin staff] }

  # === Scopes ===
  scope :owners, -> { where(role: "owner") }
  scope :admins, -> { where(role: %w[owner admin]) }

  # === Instance Methods ===
  def owner?
    role == "owner"
  end

  def admin?
    role.in?(%w[owner admin])
  end

  def staff?
    role == "staff"
  end
end
