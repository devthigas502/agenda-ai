# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Webhooks::Stripe", type: :request do
  let!(:account) { create(:account, stripe_customer_id: "cus_webhook_123", stripe_subscription_id: "sub_webhook_123", subscription_status: "trialing") }

  describe "POST /webhooks/stripe" do
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    context "when customer.subscription.updated event is received" do
      let(:payload) do
        {
          id: "evt_test_123",
          type: "customer.subscription.updated",
          data: {
            object: {
              id: "sub_webhook_123",
              customer: "cus_webhook_123",
              status: "active",
              current_period_end: 1.month.from_now.to_i,
              cancel_at_period_end: false,
              items: {
                data: [
                  {
                    price: {
                      id: "price_monthly_123",
                      recurring: { interval: "month" }
                    }
                  }
                ]
              }
            }
          }
        }.to_json
      end

      it "updates the account subscription status to active" do
        post "/webhooks/stripe", params: payload, headers: headers

        expect(response).to have_http_status(:ok)
        account.reload
        expect(account.subscription_status).to eq("active")
        expect(account.subscription_plan).to eq("monthly")
      end
    end

    context "when customer.subscription.deleted event is received" do
      let(:payload) do
        {
          id: "evt_test_deleted",
          type: "customer.subscription.deleted",
          data: {
            object: {
              id: "sub_webhook_123",
              customer: "cus_webhook_123"
            }
          }
        }.to_json
      end

      it "updates the account subscription status to canceled" do
        post "/webhooks/stripe", params: payload, headers: headers

        expect(response).to have_http_status(:ok)
        account.reload
        expect(account.subscription_status).to eq("canceled")
      end
    end

    context "when invoice.payment_failed event is received" do
      let(:payload) do
        {
          id: "evt_test_failed",
          type: "invoice.payment_failed",
          data: {
            object: {
              id: "in_123",
              customer: "cus_webhook_123",
              subscription: "sub_webhook_123"
            }
          }
        }.to_json
      end

      it "updates the account subscription status to past_due" do
        post "/webhooks/stripe", params: payload, headers: headers

        expect(response).to have_http_status(:ok)
        account.reload
        expect(account.subscription_status).to eq("past_due")
      end
    end
  end
end
