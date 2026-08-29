# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = extract_bearer_token || request.headers["X-Api-Token"] || params[:token]
        @current_user = User.find_by(api_token: token) if token.present?

        if @current_user
          ActsAsTenant.current_tenant = @current_user.account
        else
          render json: {
            status: "unauthorized",
            message: "Não autorizado: Token de API inválido ou ausente. Forneça o header 'Authorization: Bearer <seu_token>' ou parâmetro 'token'."
          }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end

      def extract_bearer_token
        auth_header = request.headers["Authorization"]
        return nil if auth_header.blank?

        match = auth_header.match(/^Bearer\s+(.*)$/i)
        match ? match[1] : nil
      end
    end
  end
end
