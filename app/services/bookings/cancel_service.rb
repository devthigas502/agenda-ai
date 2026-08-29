# frozen_string_literal: true

module Bookings
  class CancelService
    attr_reader :booking, :errors

    def initialize(booking:, reason: nil, changed_by: nil)
      @booking = booking
      @reason = reason
      @changed_by = changed_by
      @errors = []
    end

    def call
      if @booking.cancelled?
        @errors = ["Agendamento já está cancelado"]
        return self
      end

      @booking.cancel!(reason: @reason, changed_by: @changed_by)
      self
    rescue ActiveRecord::RecordInvalid => e
      @errors = e.record.errors.full_messages
      self
    end

    def success?
      errors.empty?
    end
  end
end
