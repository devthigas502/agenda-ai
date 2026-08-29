# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Registrations Flow", type: :request do
  describe "GET /signup" do
    it "renders the onboarding form" do
      get new_user_registration_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Comece seu teste grátis")
    end
  end

  describe "POST /signup" do
    context "with valid parameters" do
      let(:params) do
        {
          onboarding: {
            account_name: "Estúdio Beleza Total",
            user_name: "Ana Silva",
            email: "ana@estudiobeleza.com",
            phone: "(11) 98888-7777",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      end

      it "creates account and user, then signs in" do
        expect {
          post user_registration_path, params: params
        }.to change(Account, :count).by(1).and change(User, :count).by(1)

        expect(response).to redirect_to(admin_root_path)
        follow_redirect!
        expect(response.body).to include("Estúdio Beleza Total")
      end

      it "accepts accounts_onboarding_service param key as fallback" do
        fallback_params = { accounts_onboarding_service: params[:onboarding] }
        expect {
          post user_registration_path, params: fallback_params
        }.to change(Account, :count).by(1).and change(User, :count).by(1)

        expect(response).to redirect_to(admin_root_path)
      end
    end
  end
end
