# frozen_string_literal: true

class RegistrationsController < ApplicationController
  def new
    @onboarding = Accounts::OnboardingService.new({})
  end

  def create
    service = Accounts::OnboardingService.new(onboarding_params)
    result = service.call

    if result.success?
      sign_in(result.user)
      redirect_to admin_root_path, notice: "Conta criada com sucesso! Bem-vindo ao AgendaAI."
    else
      @errors = result.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def onboarding_params
    raw_params = params[:onboarding] || params[:accounts_onboarding_service]
    raise ActionController::ParameterMissing, :onboarding if raw_params.blank?

    raw_params.permit(
      :account_name, :user_name, :email, :phone, :password, :password_confirmation
    )
  end
end
