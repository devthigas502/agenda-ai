# frozen_string_literal: true

module Webhooks
  class StripeController < ActionController::API
    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      webhook_secret = STRIPE_WEBHOOK_SECRET

      event = nil

      if webhook_secret.present? && sig_header.present?
        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
        rescue JSON::ParserError, Stripe::SignatureVerificationError => e
          Rails.logger.error("Stripe Webhook Signature Verification Error: #{e.message}")
          return head :bad_request
        end
      else
        begin
          data = JSON.parse(payload)
          event = Stripe::Event.construct_from(data)
        rescue JSON::ParserError => e
          Rails.logger.error("Stripe Webhook JSON Parser Error: #{e.message}")
          return head :bad_request
        end
      end

      process_event(event)
      head :ok
    end

    private

    def process_event(event)
      case event.type
      when "checkout.session.completed"
        handle_checkout_session_completed(event.data.object)
      when "customer.subscription.created", "customer.subscription.updated"
        handle_subscription_updated(event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(event.data.object)
      when "invoice.payment_succeeded"
        handle_invoice_payment_succeeded(event.data.object)
      when "invoice.payment_failed"
        handle_invoice_payment_failed(event.data.object)
      else
        Rails.logger.info("Unhandled Stripe event type: #{event.type}")
      end
    end

    def handle_checkout_session_completed(session)
      return unless session.mode == "subscription" && session.subscription.present?

      account = find_account_by_session(session)
      return unless account

      stripe_sub = Stripe::Subscription.retrieve(session.subscription)
      account.update_subscription_from_stripe!(stripe_sub)
    rescue Stripe::StripeError => e
      Rails.logger.error("Error processing checkout session completed: #{e.message}")
    end

    def handle_subscription_updated(stripe_sub)
      account = find_account_by_subscription(stripe_sub)
      return unless account

      account.update_subscription_from_stripe!(stripe_sub)
    end

    def handle_subscription_deleted(stripe_sub)
      account = find_account_by_subscription(stripe_sub)
      return unless account

      account.update!(
        subscription_status: "canceled",
        subscription_cancel_at_period_end: false
      )
    end

    def handle_invoice_payment_succeeded(invoice)
      return unless invoice.subscription.present?

      account = Account.find_by(stripe_customer_id: invoice.customer) ||
                Account.find_by(stripe_subscription_id: invoice.subscription)
      return unless account

      stripe_sub = Stripe::Subscription.retrieve(invoice.subscription)
      account.update_subscription_from_stripe!(stripe_sub)
    rescue Stripe::StripeError => e
      Rails.logger.error("Error processing invoice payment succeeded: #{e.message}")
    end

    def handle_invoice_payment_failed(invoice)
      account = Account.find_by(stripe_customer_id: invoice.customer) ||
                Account.find_by(stripe_subscription_id: invoice.subscription)
      return unless account

      account.update!(subscription_status: "past_due")
    end

    def find_account_by_session(session)
      metadata = session.respond_to?(:metadata) ? session.metadata : session["metadata"]
      account_id = if metadata.respond_to?(:dig)
        metadata.dig("account_id")
      elsif metadata.respond_to?(:[])
        metadata["account_id"]
      end

      client_ref = session.respond_to?(:client_reference_id) ? session.client_reference_id : session["client_reference_id"]
      account_id ||= client_ref

      if account_id.present?
        Account.find_by(id: account_id)
      else
        customer_id = session.respond_to?(:customer) ? session.customer : session["customer"]
        Account.find_by(stripe_customer_id: customer_id)
      end
    end

    def find_account_by_subscription(stripe_sub)
      metadata = stripe_sub.respond_to?(:metadata) ? stripe_sub.metadata : stripe_sub["metadata"]
      account_id = if metadata.respond_to?(:dig)
        metadata.dig("account_id")
      elsif metadata.respond_to?(:[])
        metadata["account_id"]
      end

      if account_id.present?
        Account.find_by(id: account_id)
      else
        sub_id = stripe_sub.respond_to?(:id) ? stripe_sub.id : stripe_sub["id"]
        cus_id = stripe_sub.respond_to?(:customer) ? stripe_sub.customer : stripe_sub["customer"]
        Account.find_by(stripe_subscription_id: sub_id) || Account.find_by(stripe_customer_id: cus_id)
      end
    end
  end
end

