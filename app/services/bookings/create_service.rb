# frozen_string_literal: true

module Bookings
  class CreateService
    attr_reader :booking, :errors

    def initialize(account:, params:, source: "public_page")
      @account = account
      @params = params
      @source = source
      @errors = []
    end

    def call
      return self unless validate_account_subscription!

      ActiveRecord::Base.transaction do
        find_or_create_client!
        build_booking!
        validate_availability!
        @booking.save!
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      self
    rescue AvailabilityError => e
      @errors = [e.message]
      self
    end

    def success?
      errors.empty? && booking&.persisted?
    end

    class AvailabilityError < StandardError; end

    private

    def validate_account_subscription!
      unless @account&.subscribed?
        @errors = ["O período de testes deste estabelecimento expirou. Agendamentos temporariamente desativados."]
        return false
      end
      true
    end

    def find_or_create_client!
      @client = Client.find_or_initialize_by_phone(
        @params[:client_phone],
        name: @params[:client_name],
        email: @params[:client_email]
      )
      @client.account = @account
      @client.save! if @client.new_record? || @client.changed?
    end

    def build_booking!
      professional = @account.professionals.find(@params[:professional_id])
      service = @account.services.find(@params[:service_id])

      # Calculate effective duration and price
      ps = ProfessionalService.find_by(professional: professional, service: service)
      duration = ps&.effective_duration_minutes || service.duration_minutes
      price = ps&.effective_price_cents || service.price_cents

      starts_at = Time.zone.parse(@params[:starts_at].to_s)
      ends_at = starts_at + duration.minutes

      @booking = Booking.new(
        account: @account,
        professional: professional,
        service: service,
        client: @client,
        starts_at: starts_at,
        ends_at: ends_at,
        price_cents: price,
        currency: service.currency,
        source: @source,
        status: "pending"
      )
    end

    def validate_availability!
      date = @booking.starts_at.to_date
      calculator = Availability::CalculatorService.new(
        professional: @booking.professional,
        service: @booking.service,
        date_range: date..date
      )

      available_slots = calculator.call[date] || []
      slot_match = available_slots.any? do |slot|
        slot.starts_at == @booking.starts_at && slot.ends_at == @booking.ends_at
      end

      raise AvailabilityError, "Horário não disponível" unless slot_match
    end
  end
end
