# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Dashboard", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }

  before do
    sign_in user, scope: :user
  end

  describe "GET /admin" do
    it "renders the admin dashboard with tenant scope" do
      get admin_root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Painel de Controle")
      expect(response.body).to include(account.name)
    end
  end
end
