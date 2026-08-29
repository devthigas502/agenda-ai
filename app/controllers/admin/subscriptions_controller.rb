# frozen_string_literal: true

module Admin
  class SubscriptionsController < BaseController
    def show

      @account = current_tenant
      @plans = StripePlan::PLANS
      @current_plan = @account.subscription_plan || "monthly"
    end

    def create
      plan_id = params[:plan_id] == "yearly" ? "yearly" : "monthly"
      plan = StripePlan.find(plan_id)
      customer = current_tenant.find_or_create_stripe_customer!

      session_params = {
        mode: "subscription",
        customer: customer.id,
        payment_method_types: ["card"],
        line_items: [
          {
            price_data: {
              currency: "brl",
              unit_amount: plan[:amount_cents],
              recurring: { interval: plan[:interval] },
              product_data: {
                name: "AgendaAI — #{plan[:name]}",
                description: "Assinatura da plataforma SaaS de agendamento online AgendaAI."
              }
            },
            quantity: 1
          }
        ],
        success_url: "#{success_admin_subscription_url}?session_id={CHECKOUT_SESSION_ID}",
        cancel_url: cancel_admin_subscription_url,
        metadata: {
          account_id: current_tenant.id,
          plan_id: plan_id
        },

        subscription_data: {
          metadata: {
            account_id: current_tenant.id,
            plan_id: plan_id
          }
        }
      }

      session = Stripe::Checkout::Session.create(session_params)
      redirect_to session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      flash[:alert] = "Erro ao iniciar pagamento com Stripe: #{e.message}"
      redirect_to admin_subscription_path
    end

    def portal
      customer = current_tenant.find_or_create_stripe_customer!

      portal_session = Stripe::BillingPortal::Session.create(
        customer: customer.id,
        return_url: admin_subscription_url
      )

      redirect_to portal_session.url, allow_other_host: true, status: :see_other
    rescue Stripe::StripeError => e
      flash[:alert] = "Erro ao acessar portal do cliente Stripe: #{e.message}"
      redirect_to admin_subscription_path
    end

    def success
      if params[:session_id].present?
        begin
          checkout_session = Stripe::Checkout::Session.retrieve(params[:session_id])
          if checkout_session.subscription.present?
            stripe_sub = Stripe::Subscription.retrieve(checkout_session.subscription)
            current_tenant.update_subscription_from_stripe!(stripe_sub)
          end
        rescue Stripe::StripeError => e
          Rails.logger.warn("Could not immediately sync Stripe session: #{e.message}")
        end
      end

      flash[:notice] = "Parabéns! Sua assinatura foi confirmada com sucesso. Aproveite todos os recursos do AgendaAI."
      redirect_to admin_subscription_path
    end

    def cancel
      flash[:alert] = "O processo de assinatura foi cancelado. Você pode tentar novamente a qualquer momento."
      redirect_to admin_subscription_path
    end
  end
end
