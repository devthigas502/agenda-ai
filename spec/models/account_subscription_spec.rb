# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  describe "Stripe subscription methods" do
    let(:account) { create(:account, plan: "trial", trial_ends_at: 10.days.from_now) }

    describe "#trial_active?" do
      it "returns true when in trial and trial_ends_at is in the future" do
        expect(account.trial_active?).to be true
      end

      it "returns false when trial has expired" do
        account.update(trial_ends_at: 2.days.ago)
        expect(account.trial_active?).to be false
      end
    end

    describe "#subscribed?" do
      it "returns true when in active trial" do
        expect(account.subscribed?).to be true
      end

      it "returns true when subscription is active" do
        account.update(subscription_status: "active", plan: "starter")
        expect(account.subscribed?).to be true
      end

      it "returns false when trial expired and no active subscription" do
        account.update(trial_ends_at: 2.days.ago, subscription_status: "trialing")
        expect(account.subscribed?).to be false
      end
    end

    describe "#trial_days_left" do
      it "returns the number of days left in trial" do
        account.update(trial_ends_at: 5.days.from_now)
        expect(account.trial_days_left).to eq(5)
      end

      it "returns 0 if trial is expired" do
        account.update(trial_ends_at: 1.day.ago)
        expect(account.trial_days_left).to eq(0)
      end
    end

    describe "#plan_name" do
      it "returns 'Plano Mensal' when monthly" do
        account.update(subscription_plan: "monthly", subscription_status: "active", plan: "starter")
        expect(account.plan_name).to eq("Plano Mensal")
      end

      it "returns 'Plano Anual' when yearly" do
        account.update(subscription_plan: "yearly", subscription_status: "active", plan: "business")
        expect(account.plan_name).to eq("Plano Anual")
      end
    end

    describe "#update_subscription_from_stripe!" do
      let(:mock_price) { double("Price", id: "price_123", recurring: double("Recurring", interval: "month")) }
      let(:mock_item) { double("Item", price: mock_price) }
      let(:mock_items) { double("Items", data: [mock_item]) }
      let(:mock_stripe_sub) do
        double("Subscription",
          id: "sub_123",
          status: "active",
          items: mock_items,
          current_period_end: 1.month.from_now.to_i,
          cancel_at_period_end: false
        )
      end

      it "updates account fields accurately from Stripe subscription" do
        account.update_subscription_from_stripe!(mock_stripe_sub)
        account.reload

        expect(account.stripe_subscription_id).to eq("sub_123")
        expect(account.subscription_status).to eq("active")
        expect(account.subscription_plan).to eq("monthly")
        expect(account.subscription_cancel_at_period_end).to be false
      end
    end
  end
end
