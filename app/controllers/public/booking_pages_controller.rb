# frozen_string_literal: true

module Public
  class BookingPagesController < BaseController
    def show
      @account = current_tenant
      @services = @account.services.active.sorted
      @professionals = @account.professionals.active.sorted
    end

    def slots
      unless @account.subscribed?
        return render json: { date: params[:date], slots: [], error: "Agendamentos indisponíveis no momento" }, status: :forbidden
      end

      professional = current_tenant.professionals.find(params[:professional_id])
      service = current_tenant.services.find(params[:service_id])
      date = Date.parse(params[:date])

      calculator = Availability::CalculatorService.new(
        professional: professional,
        service: service,
        date_range: date..date
      )

      slots = calculator.call[date] || []

      render json: {
        date: date.strftime("%Y-%m-%d"),
        slots: slots.map { |s| { starts_at: s.starts_at.iso8601, formatted: s.starts_at.strftime("%H:%M") } }
      }
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
