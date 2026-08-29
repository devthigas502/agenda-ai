# frozen_string_literal: true

module Public
  class BookingsController < BaseController
    def create
      service = Bookings::CreateService.new(
        account: current_tenant,
        params: booking_params,
        source: "public_page"
      )
      result = service.call

      if result.success?
        redirect_to public_booking_confirmation_path(slug: current_tenant.slug, id: result.booking.id)
      else
        redirect_to public_booking_page_path(slug: current_tenant.slug),
                    alert: "Erro ao criar agendamento: #{result.errors.join(', ')}"
      end
    end

    def confirmation
      @booking = current_tenant.bookings.find(params[:id])
    end

    private

    def booking_params
      params.require(:booking).permit(
        :professional_id, :service_id, :starts_at, :client_name, :client_phone, :client_email
      )
    end
  end
end
