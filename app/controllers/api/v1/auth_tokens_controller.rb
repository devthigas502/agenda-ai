# frozen_string_literal: true

module Api
  module V1
    class AuthTokensController < ActionController::API
      def create
        email = params[:email]&.strip&.downcase
        password = params[:password]

        user = User.find_by(email: email)

        if user&.valid_password?(password)
          user.regenerate_api_token if user.api_token.blank?
          
          render json: {
            status: "success",
            message: "Token gerado com sucesso!",
            token: user.api_token,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role
            },
            account: {
              id: user.account.id,
              name: user.account.name,
              slug: user.account.slug
            }
          }, status: :ok
        else
          render json: {
            status: "error",
            message: "Credenciais inválidas. Verifique seu e-mail e senha."
          }, status: :unauthorized
        end
      end
    end
  end
end
