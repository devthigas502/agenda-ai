# frozen_string_literal: true

module Admin
  class ProfessionalsController < BaseController
    before_action :set_professional, only: %i[show edit update destroy]

    def index
      @professionals = current_tenant.professionals.sorted
    end

    def show
      @schedules = @professional.schedules.order(:weekday, :starts_at)
      @overrides = @professional.schedule_overrides.order(date: :asc)
    end

    def new
      @professional = current_tenant.professionals.build
    end

    def create
      @professional = current_tenant.professionals.build(professional_params)
      if @professional.save
        redirect_to admin_professionals_path, notice: "Profissional cadastrado com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @professional.update(professional_params)
        redirect_to admin_professionals_path, notice: "Profissional atualizado com sucesso."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @professional.destroy
        redirect_to admin_professionals_path, notice: "Profissional removido com sucesso."
      else
        redirect_to admin_professionals_path, alert: "Não é possível remover profissional com agendamentos vinculados."
      end
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:id])
    end

    def professional_params
      params.require(:professional).permit(:name, :email, :phone, :bio, :active, :position, service_ids: [])
    end
  end
end
