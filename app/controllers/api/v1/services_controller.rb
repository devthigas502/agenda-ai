# frozen_string_literal: true

module Api
  module V1
    class ServicesController < BaseController
      def create
        service = current_user.account.services.new(service_params)
        service.currency = "BRL" if service.currency.blank?

        if service.save
          render json: {
            status: "success",
            message: "Serviço cadastrado com sucesso!",
            service: {
              id: service.id,
              name: service.name,
              description: service.description,
              duration_minutes: service.duration_minutes,
              formatted_duration: service.formatted_duration,
              price_cents: service.price_cents,
              price_reais: service.price_in_reais,
              formatted_price: service.formatted_price,
              currency: service.currency,
              active: service.active,
              created_at: service.created_at
            }
          }, status: :created
        else
          render json: {
            status: "error",
            message: "Falha ao cadastrar serviço.",
            errors: service.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def service_params
        # Supports payload nested under :service or flat parameters
        raw_params = params[:service].is_a?(ActionController::Parameters) ? params.require(:service) : params
        raw_params.permit(:name, :description, :duration_minutes, :price_cents, :price_reais, :currency, :active)
      end
    end
  end
end
