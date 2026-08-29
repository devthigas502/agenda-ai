# frozen_string_literal: true

module Admin
  class SchedulesController < BaseController
    before_action :set_professional

    def index
      @schedules = @professional.schedules.order(:weekday, :starts_at)
      @schedule = @professional.schedules.build
    end

    def create
      @schedule = @professional.schedules.build(schedule_params)
      if @schedule.save
        redirect_to admin_professional_schedules_path(@professional), notice: "Horário adicionado com sucesso."
      else
        @schedules = @professional.schedules.order(:weekday, :starts_at)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      schedule = @professional.schedules.find(params[:id])
      schedule.destroy
      redirect_to admin_professional_schedules_path(@professional), notice: "Horário removido."
    end

    private

    def set_professional
      @professional = current_tenant.professionals.find(params[:professional_id])
    end

    def schedule_params
      params.require(:schedule).permit(:weekday, :starts_at, :ends_at)
    end
  end
end
