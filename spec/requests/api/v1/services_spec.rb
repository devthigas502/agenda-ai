# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Services", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:token) { user.api_token }

  describe "POST /api/v1/services" do
    context "with valid bearer token and parameters" do
      it "creates a new service associated with the account" do
        headers = { "Authorization" => "Bearer #{token}" }
        params = {
          service: {
            name: "Corte Masculino Degradê",
            description: "Corte na tesoura e máquina com finalização",
            duration_minutes: 45,
            price_reais: 45.5,
            active: true
          }
        }

        expect {
          post api_v1_services_path, params: params, headers: headers
        }.to change(account.services, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["service"]["name"]).to eq("Corte Masculino Degradê")
        expect(json["service"]["duration_minutes"]).to eq(45)
        expect(json["service"]["price_cents"]).to eq(4550)
        expect(json["service"]["formatted_price"]).to include("45,50")
      end
    end

    context "with flat parameters (without nesting under service:)" do
      it "creates the service successfully" do
        headers = { "Authorization" => "Bearer #{token}" }
        params = {
          name: "Barba Terapia",
          duration_minutes: 30,
          price_cents: 3500
        }

        expect {
          post api_v1_services_path, params: params, headers: headers
        }.to change(account.services, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["service"]["name"]).to eq("Barba Terapia")
        expect(json["service"]["price_cents"]).to eq(3500)
      end
    end

    context "without authentication token" do
      it "returns unauthorized status" do
        post api_v1_services_path, params: { name: "Massagem", duration_minutes: 60, price_cents: 10000 }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity with error messages" do
        headers = { "Authorization" => "Bearer #{token}" }
        params = {
          service: {
            name: "",
            duration_minutes: 0
          }
        }

        post api_v1_services_path, params: params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
        expect(json["errors"]).to be_present
      end
    end
  end
end
