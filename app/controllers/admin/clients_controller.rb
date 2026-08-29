# frozen_string_literal: true

module Admin
  class ClientsController < BaseController
    def index
      @query = params[:q]
      @clients = current_tenant.clients.order(name: :asc)
      @clients = @clients.search(@query) if @query.present?
    end

    def show
      @client = current_tenant.clients.find(params[:id])
      @bookings = @client.bookings.order(starts_at: :desc)
    end
  end
end
