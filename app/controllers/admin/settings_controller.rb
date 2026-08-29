# frozen_string_literal: true

module Admin
  class SettingsController < BaseController
    def show
      @account = current_tenant
    end

    def update
      @account = current_tenant
      if @account.update(account_params)
        redirect_to admin_settings_path, notice: "Configurações atualizadas."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def account_params
      params.require(:account).permit(:name, :slug, :phone, :email, :timezone)
    end
  end
end
