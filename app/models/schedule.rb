# frozen_string_literal: true

class Schedule < ApplicationRecord
  belongs_to :professional

  # === Validations ===
  validates :weekday, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_at_after_starts_at

  # === Scopes ===
  scope :for_weekday, ->(day) { where(weekday: day) }

  # Day name helpers
  DAY_NAMES = %w[Domingo Segunda Terça Quarta Quinta Sexta Sábado].freeze

  def day_name
    DAY_NAMES[weekday]
  end

  private

  def ends_at_after_starts_at
    return unless starts_at && ends_at

    errors.add(:ends_at, "deve ser posterior ao horário de início") if ends_at <= starts_at
  end
end
