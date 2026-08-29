# frozen_string_literal: true

class Account < ApplicationRecord
  include Sluggable

  slug_source :name

  # === Associations ===
  has_many :users, dependent: :destroy
  has_many :professionals, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :bookings, dependent: :destroy

  # === Validations ===
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :plan, presence: true, inclusion: { in: %w[trial starter professional business] }
  validates :timezone, presence: true

  # === Callbacks ===
  before_create :set_trial_end_date

  # === Instance Methods ===
  def trial?
    plan == "trial" && (subscription_status == "trialing" || subscription_status.blank?)
  end

  def trial_active?
    trial? && trial_ends_at.present? && trial_ends_at.future?
  end

  def trial_expired?
    trial? && (trial_ends_at.blank? || trial_ends_at.past?)
  end

  def trial_days_left
    return 0 unless trial_ends_at&.future?

    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  def subscribed?
    subscription_active? || trial_active?
  end

  def subscription_active?
    subscription_status == "active"
  end

  def subscription_past_due?
    subscription_status == "past_due"
  end

  def subscription_canceled?
    subscription_status == "canceled"
  end

  def plan_name
    return "Período de Testes (14 dias)" if trial_active?
    return "Teste Expirado" if trial_expired? && !subscription_active?

    case subscription_plan
    when "yearly" then "Plano Anual"
    when "monthly" then "Plano Mensal"
    else "Plano #{plan&.titleize}"
    end
  end

  def plan_details
    StripePlan.find(subscription_plan || "monthly")
  end

  def find_or_create_stripe_customer!
    return Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id.present?

    customer = Stripe::Customer.create(
      name: name,
      email: email.presence || users.first&.email,
      metadata: {
        account_id: id,
        account_slug: slug
      }
    )

    update_column(:stripe_customer_id, customer.id)
    customer
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe customer creation error for Account #{id}: #{e.message}")
    raise e
  end

  def update_subscription_from_stripe!(stripe_sub)
    items_data = if stripe_sub.respond_to?(:items) && stripe_sub.items.respond_to?(:data)
      stripe_sub.items.data
    elsif stripe_sub.respond_to?(:[]) && stripe_sub["items"]
      stripe_sub["items"]["data"] || []
    else
      []
    end

    first_item = items_data.first
    interval = if first_item.respond_to?(:price) && first_item.price.respond_to?(:recurring)
      first_item.price.recurring&.interval
    elsif first_item.respond_to?(:dig)
      first_item.dig("price", "recurring", "interval")
    end
    detected_plan = interval == "year" ? "yearly" : "monthly"

    price_id = if first_item.respond_to?(:price) && first_item.price.respond_to?(:id)
      first_item.price.id
    elsif first_item.respond_to?(:dig)
      first_item.dig("price", "id")
    end

    period_end_timestamp = if stripe_sub.respond_to?(:current_period_end)
      stripe_sub.current_period_end
    elsif stripe_sub.respond_to?(:[])
      stripe_sub["current_period_end"]
    end
    period_end = period_end_timestamp ? Time.at(period_end_timestamp) : nil

    cancel_at_period_end = if stripe_sub.respond_to?(:cancel_at_period_end)
      stripe_sub.cancel_at_period_end || false
    elsif stripe_sub.respond_to?(:[])
      stripe_sub["cancel_at_period_end"] || false
    else
      false
    end

    sub_id = stripe_sub.respond_to?(:id) ? stripe_sub.id : stripe_sub["id"]
    sub_status = stripe_sub.respond_to?(:status) ? stripe_sub.status : stripe_sub["status"]

    update!(
      stripe_subscription_id: sub_id,
      stripe_price_id: price_id,
      subscription_status: sub_status || "active",
      subscription_plan: detected_plan,
      plan: detected_plan == "yearly" ? "business" : "starter",
      subscription_current_period_end: period_end,
      subscription_cancel_at_period_end: cancel_at_period_end
    )
  end


  private

  def set_trial_end_date
    self.trial_ends_at ||= 14.days.from_now
  end
end

