# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Bookings", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /admin/bookings" do
    it "renders the bookings list" do
      get admin_bookings_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Gestão de Agendamentos")
    end
  end

  context "when trial has expired and no active subscription" do
    before do
      account.update_column(:trial_ends_at, 1.day.ago)
    end

    it "redirects GET /admin/bookings/new to subscriptions page" do
      get new_admin_booking_path
      expect(response).to redirect_to(admin_subscription_path)
      follow_redirect!
      expect(response.body).to include("Seu período de testes de 14 dias expirou")
    end

    it "blocks POST /admin/bookings and redirects to subscriptions page" do
      post admin_bookings_path, params: {
        booking: {
          client_name: "Teste",
          client_phone: "11999999999"
        }
      }
      expect(response).to redirect_to(admin_subscription_path)
      follow_redirect!
      expect(response.body).to include("Seu período de testes de 14 dias expirou")
    end
  end
end
