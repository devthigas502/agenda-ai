# frozen_string_literal: true

require "stripe"

# Configure Stripe API keys with fallback for development and test
Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY") {
  if Rails.env.production?
    Rails.application.credentials.dig(:stripe, :secret_key) ||
      raise("STRIPE_SECRET_KEY or credentials :stripe :secret_key is required in production")
  else
    Rails.application.credentials.dig(:stripe, :secret_key) ||
      "sk_test_51RTmU5E4uFrfIgDB6IDVuqPJysew3V4lrWdncvGiMdZqHhylZYM0zNPfVpJjM34HzHaBfhnapBQFCWvf7212kwvD00EwzlY3oT"
  end
}

STRIPE_PUBLISHABLE_KEY = ENV.fetch("STRIPE_PUBLISHABLE_KEY") {
  if Rails.env.production?
    Rails.application.credentials.dig(:stripe, :publishable_key) ||
      raise("STRIPE_PUBLISHABLE_KEY or credentials :stripe :publishable_key is required in production")
  else
    Rails.application.credentials.dig(:stripe, :publishable_key) ||
      "pk_test_51RTmU5E4uFrfIgDBkRFzL5KfNwoXbpcvWdQC0q5Jn5HIiGr18YE1hTZJFIkc9fhWcoiuIpAiIXjUT8horKMrooTZ00qOx47kws"
  end
}


STRIPE_WEBHOOK_SECRET = ENV.fetch("STRIPE_WEBHOOK_SECRET") {
  Rails.application.credentials.dig(:stripe, :webhook_secret)
}

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
