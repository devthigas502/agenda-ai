# frozen_string_literal: true

class ScheduleOverride < ApplicationRecord
  belongs_to :professional

  # === Validations ===
  validates :date, presence: true
  validates :date, uniqueness: { scope: :professional_id, message: "já possui uma exceção cadastrada" }
  validate :time_range_when_not_blocked

  # === Scopes ===
  scope :for_date, ->(date) { where(date: date) }
  scope :blocked, -> { where(blocked: true) }
  scope :available, -> { where(blocked: false) }

  def full_day_blocked?
    blocked?
  end

  private

  def time_range_when_not_blocked
    return if blocked?

    if starts_at.blank? || ends_at.blank?
      errors.add(:base, "horários de início e fim são obrigatórios quando não é bloqueio total")
    elsif ends_at <= starts_at
      errors.add(:ends_at, "deve ser posterior ao horário de início")
    end
  end
end
