# frozen_string_literal: true

require "stripe"

# Configure Stripe API keys with fallback for development, test, and build
stripe_creds = begin
  Rails.application.credentials.stripe if Rails.application.credentials.present?
rescue StandardError
  nil
end

Stripe.api_key = ENV["STRIPE_SECRET_KEY"].presence ||
  stripe_creds&.dig(:secret_key) ||
  "sk_test_51RTmU5E4uFrfIgDB6IDVuqPJysew3V4lrWdncvGiMdZqHhylZYM0zNPfVpJjM34HzHaBfhnapBQFCWvf7212kwvD00EwzlY3oT"

STRIPE_PUBLISHABLE_KEY = ENV["STRIPE_PUBLISHABLE_KEY"].presence ||
  stripe_creds&.dig(:publishable_key) ||
  "pk_test_51RTmU5E4uFrfIgDBkRFzL5KfNwoXbpcvWdQC0q5Jn5HIiGr18YE1hTZJFIkc9fhWcoiuIpAiIXjUT8horKMrooTZ00qOx47kws"

STRIPE_WEBHOOK_SECRET = ENV["STRIPE_WEBHOOK_SECRET"].presence ||
  stripe_creds&.dig(:webhook_secret)

module StripePlan
  MONTHLY = {
    id: "monthly",
    name: "Plano Mensal",
    amount_cents: 7990,
    interval: "month",
    formatted_price: "R$ 79,90/mês",
    price_display: "R$ 79,90",
    interval_display: "por mês",
    features: [
      "Agendamentos ilimitados 24/7",
      "Página pública personalizada",
      "Múltiplos profissionais e serviços",
      "Controle de horários e bloqueios",
      "Notificações automáticas",
      "Painel de métricas e relatórios",
      "Suporte prioritário"
    ]
  }.freeze

  YEARLY = {
    id: "yearly",
    name: "Plano Anual",
    amount_cents: 54900,
    interval: "year",
    formatted_price: "R$ 549,00/ano",
    price_display: "R$ 549,00",
    interval_display: "por ano",
    monthly_equivalent: "R$ 45,75/mês",
    savings_display: "Economize R$ 409,80/ano (42% OFF)",
    badge: "Mais Popular — 42% OFF",
    features: [
      "Tudo do Plano Mensal incluído",
      "Economia anual de R$ 409,80",
      "Equivalente a R$ 45,75/mês",
      "Acesso antecipado a novos recursos",
      "Gerenciamento avançado de equipe",
      "Exportação de dados e relatórios",
      "Atendimento VIP e onboarding dedicado"
    ]
  }.freeze

  PLANS = {
    "monthly" => MONTHLY,
    "yearly" => YEARLY
  }.freeze

  def self.find(plan_id)
    PLANS[plan_id.to_s] || MONTHLY
  end
end
