# frozen_string_literal: true

module Admin
  class BookingsController < BaseController
    before_action :ensure_active_subscription!, only: %i[new create]
    before_action :set_booking, only: %i[show confirm complete cancel no_show]

    def index
      @status = params[:status]
      @professional_id = params[:professional_id]

      @bookings = current_tenant.bookings.includes(:professional, :service, :client).order(starts_at: :desc)
      @bookings = @bookings.by_status(@status) if @status.present?
      @bookings = @bookings.for_professional(@professional_id) if @professional_id.present?
    end

    def show; end

    def new
      @booking = current_tenant.bookings.build
      @professionals = current_tenant.professionals.active
      @services = current_tenant.services.active
    end

    def create
      service = Bookings::CreateService.new(
        account: current_tenant,
        params: booking_params,
        source: "admin"
      )
      result = service.call

      if result.success?
        redirect_to admin_bookings_path, notice: "Agendamento criado com sucesso!"
      else
        @errors = result.errors
        @booking = current_tenant.bookings.build
        @professionals = current_tenant.professionals.active
        @services = current_tenant.services.active
        render :new, status: :unprocessable_entity
      end
    end

    def confirm
      @booking.confirm!
      redirect_to admin_bookings_path, notice: "Agendamento confirmado!"
    end

    def complete
      @booking.complete!
      redirect_to admin_bookings_path, notice: "Agendamento marcado como concluído!"
    end

    def cancel
      service = Bookings::CancelService.new(booking: @booking, reason: params[:reason], changed_by: current_user.name)
      if service.call.success?
        redirect_to admin_bookings_path, notice: "Agendamento cancelado."
      else
        redirect_to admin_bookings_path, alert: service.errors.join(", ")
      end
    end

    def no_show
      @booking.no_show!
      redirect_to admin_bookings_path, notice: "Agendamento marcado como No-Show."
    end

    private

    def set_booking
      @booking = current_tenant.bookings.find(params[:id])
    end

    def booking_params
      params.require(:booking).permit(
        :professional_id, :service_id, :starts_at, :client_name, :client_phone, :client_email
      )
    end

    def ensure_active_subscription!
      unless current_tenant&.subscribed?
        redirect_to admin_subscription_path, alert: "Seu período de testes de 14 dias expirou. Ative sua assinatura para criar novos agendamentos."
      end
    end
  end
end
