# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Subscriptions", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /admin/subscription" do
    it "renders the subscription page with plans and pricing" do
      get admin_subscription_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Assinatura")
      expect(response.body).to include("79,90")
      expect(response.body).to include("549,00")
      expect(response.body).to include("Plano Mensal")
      expect(response.body).to include("Plano Anual")
    end
  end


  describe "POST /admin/subscription" do
    let(:mock_session) { double("Session", url: "https://checkout.stripe.com/pay/cs_test_123") }

    it "creates a Stripe Checkout session for monthly plan and redirects" do
      allow(account).to receive(:find_or_create_stripe_customer!).and_return(double("Customer", id: "cus_123"))
      allow(Stripe::Checkout::Session).to receive(:create).and_return(mock_session)

      post admin_subscription_path, params: { plan_id: "monthly" }
      expect(response).to redirect_to("https://checkout.stripe.com/pay/cs_test_123")
    end

    it "creates a Stripe Checkout session for yearly plan and redirects" do
      allow(account).to receive(:find_or_create_stripe_customer!).and_return(double("Customer", id: "cus_123"))
      allow(Stripe::Checkout::Session).to receive(:create).and_return(mock_session)

      post admin_subscription_path, params: { plan_id: "yearly" }
      expect(response).to redirect_to("https://checkout.stripe.com/pay/cs_test_123")
    end
  end

  describe "POST /admin/subscription/portal" do
    let(:mock_portal_session) { double("PortalSession", url: "https://billing.stripe.com/p/session/test_123") }

    it "creates a Customer Portal session and redirects" do
      allow(account).to receive(:find_or_create_stripe_customer!).and_return(double("Customer", id: "cus_123"))
      allow(Stripe::BillingPortal::Session).to receive(:create).and_return(mock_portal_session)

      post portal_admin_subscription_path
      expect(response).to redirect_to("https://billing.stripe.com/p/session/test_123")
    end
  end

  describe "GET /admin/subscription/success" do
    it "redirects to subscription path with success flash message" do
      get success_admin_subscription_path
      expect(response).to redirect_to(admin_subscription_path)
      follow_redirect!
      expect(response.body).to include("Parabéns! Sua assinatura foi confirmada")
    end
  end

  describe "GET /admin/subscription/cancel" do
    it "redirects to subscription path with cancel flash message" do
      get cancel_admin_subscription_path
      expect(response).to redirect_to(admin_subscription_path)
      follow_redirect!
      expect(response.body).to include("cancelado")
    end
  end
end
