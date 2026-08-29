# frozen_string_literal: true

class Booking < ApplicationRecord
  acts_as_tenant :account

  # === Associations ===
  belongs_to :professional
  belongs_to :service
  belongs_to :client
  has_many :status_changes, class_name: "BookingStatusChange", dependent: :destroy

  # === Constants ===
  STATUSES = %w[pending confirmed completed cancelled no_show].freeze
  SOURCES = %w[public_page admin api].freeze

  # === Validations ===
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :price_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :ends_at_after_starts_at
  validate :no_overlapping_bookings, on: :create
  validate :account_has_active_subscription, on: :create

  # === Scopes ===
  scope :active, -> { where.not(status: "cancelled") }
  scope :upcoming, -> { where("starts_at > ?", Time.current).order(starts_at: :asc) }
  scope :for_date, ->(date) { where(starts_at: date.all_day) }
  scope :for_professional, ->(professional_id) { where(professional_id: professional_id) }
  scope :by_status, ->(status) { where(status: status) }

  # === State Transitions ===
  def confirm!
    transition_to!("confirmed")
  end

  def complete!
    transition_to!("completed")
  end

  def cancel!(reason: nil, changed_by: nil)
    transition_to!("cancelled", reason: reason, changed_by: changed_by)
  end

  def no_show!
    transition_to!("no_show")
  end

  # === Helpers ===
  def duration_minutes
    return 0 unless starts_at && ends_at

    ((ends_at - starts_at) / 60).to_i
  end

  def formatted_duration
    service&.formatted_duration || "#{duration_minutes}min"
  end

  def price_in_reais
    price_cents / 100.0
  end

  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def completed?
    status == "completed"
  end

  def cancelled?
    status == "cancelled"
  end

  def no_show?
    status == "no_show"
  end

  private

  def ends_at_after_starts_at
    return unless starts_at && ends_at

    errors.add(:ends_at, "deve ser posterior ao horário de início") if ends_at <= starts_at
  end

  def no_overlapping_bookings
    return unless starts_at && ends_at && professional_id

    overlapping = Booking.active
                         .where(professional_id: professional_id)
                         .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)

    overlapping = overlapping.where.not(id: id) if persisted?

    errors.add(:base, "conflito de horário com outro agendamento") if overlapping.exists?
  end

  def account_has_active_subscription
    return unless account

    unless account.subscribed?
      errors.add(:base, "O período de testes deste estabelecimento expirou. Assine um plano para continuar realizando agendamentos.")
    end
  end

  def transition_to!(new_status, reason: nil, changed_by: nil)
    old_status = status
    update!(status: new_status)

    status_changes.create!(
      from_status: old_status,
      to_status: new_status,
      reason: reason,
      changed_by: changed_by
    )
  end
end
