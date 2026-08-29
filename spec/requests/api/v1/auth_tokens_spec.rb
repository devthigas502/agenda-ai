# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::AuthTokens", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account, password: "password123") }

  describe "POST /api/v1/auth/token" do
    context "with valid credentials" do
      it "returns a valid API token and account information" do
        post api_v1_auth_token_path, params: { email: user.email, password: "password123" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("success")
        expect(json["token"]).to be_present
        expect(json["token"]).to eq(user.reload.api_token)
        expect(json["account"]["name"]).to eq(account.name)
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized status" do
        post api_v1_auth_token_path, params: { email: user.email, password: "wrongpassword" }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
      end
    end
  end
end
