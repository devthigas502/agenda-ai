# frozen_string_literal: true

require "rails_helper"

RSpec.describe Account, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:users).dependent(:destroy) }
    it { is_expected.to have_many(:professionals).dependent(:destroy) }
    it { is_expected.to have_many(:services).dependent(:destroy) }
    it { is_expected.to have_many(:clients).dependent(:destroy) }
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:account) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:plan).in_array(%w[trial starter professional business]) }
  end

  describe "callbacks" do
    it "sets trial_ends_at on creation" do
      account = create(:account)
      expect(account.trial_ends_at).to be_present
      expect(account.trial_ends_at).to be > Time.current
    end
  end

  describe "slug generation" do
    it "generates a slug from the name on create" do
      account = create(:account, name: "Salão Beleza & Estilo", slug: nil)
      expect(account.slug).to eq("salao-beleza-estilo")
    end
  end

  describe "trial and subscription states" do
    let(:account) { create(:account, plan: "trial", trial_ends_at: 10.days.from_now) }

    it "recognizes active trial" do
      expect(account.trial_active?).to be true
      expect(account.trial_expired?).to be false
      expect(account.subscribed?).to be true
    end

    it "recognizes expired trial when trial_ends_at is in the past" do
      account.update_column(:trial_ends_at, 1.day.ago)
      expect(account.trial_active?).to be false
      expect(account.trial_expired?).to be true
      expect(account.subscribed?).to be false
    end

    it "recognizes active subscription even if trial date passed" do
      account.update_columns(
        trial_ends_at: 1.day.ago,
        subscription_status: "active",
        plan: "starter"
      )
      expect(account.subscription_active?).to be true
      expect(account.subscribed?).to be true
    end
  end
end
