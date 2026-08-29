# frozen_string_literal: true

require "rails_helper"

RSpec.describe Availability::CalculatorService do
  let(:account) { create(:account) }
  let(:professional) { create(:professional, account: account) }
  let(:service) { create(:service, account: account, duration_minutes: 30) }

  before do
    ActsAsTenant.current_tenant = account
  end

  describe "#call" do
    context "when professional has weekly schedule" do
      # Next Monday
      let(:target_date) { Date.current.next_week(:monday) }

      before do
        create(:schedule, professional: professional, weekday: 1,
               starts_at: Time.parse("09:00"), ends_at: Time.parse("11:00"))
      end

      it "calculates correct time slots for the service duration" do
        calculator = described_class.new(
          professional: professional,
          service: service,
          date_range: target_date..target_date
        )

        slots = calculator.call[target_date]
        expect(slots).to be_present
        expect(slots.size).to eq(4) # 09:00, 09:30, 10:00, 10:30
      end

      it "excludes slots that conflict with existing bookings" do
        client = create(:client, account: account)
        zone = ActiveSupport::TimeZone[account.timezone]
        start_time = zone.local(target_date.year, target_date.month, target_date.day, 9, 30)

        create(:booking, account: account, professional: professional, service: service,
               client: client, starts_at: start_time, ends_at: start_time + 30.minutes, status: "confirmed")

        calculator = described_class.new(
          professional: professional,
          service: service,
          date_range: target_date..target_date
        )

        slots = calculator.call[target_date]
        expect(slots.map { |s| s.starts_at.strftime("%H:%M") }).to eq(%w[09:00 10:00 10:30])
      end
    end
  end
end
