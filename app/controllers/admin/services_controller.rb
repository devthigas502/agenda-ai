# frozen_string_literal: true

module Admin
  class ServicesController < BaseController
    before_action :set_service, only: %i[edit update destroy]

    def index
      @services = current_tenant.services.sorted
    end

    def new
      @service = current_tenant.services.build
    end

    def create
      @service = current_tenant.services.build(service_params)
      if @service.save
        redirect_to admin_services_path, notice: "Serviço criado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @service.update(service_params)
        redirect_to admin_services_path, notice: "Serviço atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @service.destroy
        redirect_to admin_services_path, notice: "Serviço removido com sucesso."
      else
        redirect_to admin_services_path, alert: "Não é possível remover serviço com agendamentos vinculados."
      end
    end

    private

    def set_service
      @service = current_tenant.services.find(params[:id])
    end

    def service_params
      params.require(:service).permit(:name, :description, :duration_minutes, :price_reais, :currency, :active, :position)
    end
  end
end
