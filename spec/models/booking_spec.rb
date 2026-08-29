# frozen_string_literal: true

require "rails_helper"

RSpec.describe Booking, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:professional) }
    it { is_expected.to belong_to(:service) }
    it { is_expected.to belong_to(:client) }
    it { is_expected.to have_many(:status_changes).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:booking) }

    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Booking::STATUSES) }
    it { is_expected.to validate_inclusion_of(:source).in_array(Booking::SOURCES) }
  end

  describe "overlap validation" do
    let(:account) { create(:account) }
    let(:professional) { create(:professional, account: account) }
    let(:service) { create(:service, account: account) }
    let(:client) { create(:client, account: account) }

    before do
      ActsAsTenant.current_tenant = account
    end

    it "prevents overlapping active bookings for the same professional" do
      start_time = 1.day.from_now.change(hour: 10, min: 0)

      create(:booking,
             account: account,
             professional: professional,
             service: service,
             client: client,
             starts_at: start_time,
             ends_at: start_time + 30.minutes,
             status: "confirmed")

      overlapping = build(:booking,
                          account: account,
                          professional: professional,
                          service: service,
                          client: client,
                          starts_at: start_time + 15.minutes,
                          ends_at: start_time + 45.minutes)

      expect(overlapping).not_to be_valid
      expect(overlapping.errors[:base]).to include("conflito de horário com outro agendamento")
    end
  end

  describe "status predicate methods" do
    Booking::STATUSES.each do |st|
      it "correctly identifies #{st} status" do
        booking = build(:booking, status: st)
        expect(booking.public_send("#{st}?")).to be true
      end
    end
  end

  describe "subscription validation on create" do
    let(:account) { create(:account, plan: "trial", trial_ends_at: 1.day.ago) }
    let(:professional) { create(:professional, account: account) }
    let(:service) { create(:service, account: account) }
    let(:client) { create(:client, account: account) }

    before do
      ActsAsTenant.current_tenant = account
    end

    it "rejects creation when account subscription/trial is expired" do
      booking = build(:booking,
                      account: account,
                      professional: professional,
                      service: service,
                      client: client)

      expect(booking).not_to be_valid
      expect(booking.errors[:base]).to include("O período de testes deste estabelecimento expirou. Assine um plano para continuar realizando agendamentos.")
    end

    it "allows saving/updating existing bookings even if trial has expired" do
      # Create when active
      account.update_column(:trial_ends_at, 1.day.from_now)
      booking = create(:booking,
                       account: account,
                       professional: professional,
                       service: service,
                       client: client)

      # Now trial expires
      account.update_column(:trial_ends_at, 1.day.ago)
      expect { booking.cancel! }.not_to raise_error
      expect(booking.reload.status).to eq("cancelled")
    end
  end
end
