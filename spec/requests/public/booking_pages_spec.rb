# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Public Booking Engine", type: :request do
  let!(:account) { create(:account, slug: "clinica-sorriso") }
  let!(:professional) { create(:professional, account: account) }
  let!(:service) { create(:service, account: account) }

  before do
    create(:schedule, professional: professional, weekday: Date.tomorrow.wday,
           starts_at: Time.parse("09:00"), ends_at: Time.parse("17:00"))
  end

  describe "GET /:slug" do
    it "renders the public booking page for the given tenant slug" do
      get public_booking_page_path(slug: "clinica-sorriso")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("clinica-sorriso")
      expect(response.body).to include(service.name)
      expect(response.body).to include(professional.name)
    end
  end

  describe "GET /:slug/slots" do
    it "returns available JSON time slots" do
      get public_booking_slots_path(
        slug: "clinica-sorriso",
        professional_id: professional.id,
        service_id: service.id,
        date: Date.tomorrow.strftime("%Y-%m-%d")
      )

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["slots"]).to be_an(Array)
    end
  end

  describe "GET /:slug/bookings/:id/confirmation" do
    let!(:client) { create(:client, account: account) }
    let!(:booking) { create(:booking, account: account, professional: professional, service: service, client: client) }

    it "renders the booking confirmation page with account details" do
      get public_booking_confirmation_path(slug: "clinica-sorriso", id: booking.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(account.name)
      expect(response.body).to include(service.name)
    end
  end

  context "when account trial has expired" do
    before do
      account.update_column(:trial_ends_at, 1.day.ago)
    end

    it "displays the unavailable notice on the public page instead of booking form" do
      get public_booking_page_path(slug: "clinica-sorriso")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Agendamentos Temporariamente Indisponíveis")
      expect(response.body).not_to include("booking-form")
    end

    it "denies slots request with forbidden status" do
      get public_booking_slots_path(
        slug: "clinica-sorriso",
        professional_id: professional.id,
        service_id: service.id,
        date: Date.tomorrow.strftime("%Y-%m-%d")
      )

      expect(response).to have_http_status(:forbidden)
      json = JSON.parse(response.body)
      expect(json["slots"]).to eq([])
    end

    it "prevents creating new bookings via POST /:slug/bookings" do
      post public_bookings_path(slug: "clinica-sorriso"), params: {
        booking: {
          professional_id: professional.id,
          service_id: service.id,
          starts_at: 1.day.from_now.change(hour: 10, min: 0).iso8601,
          client_name: "Ana Silva",
          client_phone: "11999999999",
          client_email: "ana@email.com"
        }
      }

      expect(response).to redirect_to(public_booking_page_path(slug: "clinica-sorriso"))
      follow_redirect!
      expect(response.body).to include("O período de testes deste estabelecimento expirou")
    end
  end
end
