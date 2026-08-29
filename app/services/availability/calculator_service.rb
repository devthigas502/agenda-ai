# frozen_string_literal: true

module Availability
  # Calculates available time slots for a professional on a given date range.
  #
  # Usage:
  #   slots = Availability::CalculatorService.new(
  #     professional: professional,
  #     service: service,
  #     date_range: Date.today..Date.today + 7.days
  #   ).call
  #
  # Returns: Hash { Date => Array<TimeSlot> }
  class CalculatorService
    TimeSlot = Struct.new(:starts_at, :ends_at, keyword_init: true)

    def initialize(professional:, service:, date_range:, buffer_minutes: 0)
      @professional = professional
      @service = service
      @date_range = date_range
      @buffer_minutes = buffer_minutes
      @duration = effective_duration
    end

    def call
      result = {}
      @date_range.each do |date|
        slots = available_slots_for(date)
        result[date] = slots if slots.any?
      end
      result
    end

    private

    def effective_duration
      ps = ProfessionalService.find_by(
        professional: @professional,
        service: @service
      )
      ps&.effective_duration_minutes || @service.duration_minutes
    end

    def available_slots_for(date)
      # 1. Get working hours for this date
      working_ranges = working_hours_for(date)
      return [] if working_ranges.empty?

      # 2. Get existing bookings for this date
      booked_ranges = booked_ranges_for(date)

      # 3. Generate slots from available time
      slots = []
      working_ranges.each do |range|
        slots.concat(generate_slots(date, range, booked_ranges))
      end

      # 4. Filter out past slots
      slots.select { |slot| slot.starts_at > Time.current }
    end

    def working_hours_for(date)
      # Check for override first
      override = @professional.schedule_overrides.for_date(date).first

      if override
        return [] if override.full_day_blocked?
        return [{ starts_at: override.starts_at, ends_at: override.ends_at }]
      end

      # Fall back to regular schedule
      @professional.schedules.for_weekday(date.wday).map do |schedule|
        { starts_at: schedule.starts_at, ends_at: schedule.ends_at }
      end
    end

    def booked_ranges_for(date)
      @professional.bookings
                   .active
                   .for_date(date)
                   .pluck(:starts_at, :ends_at)
                   .map { |s, e| { starts_at: s, ends_at: e } }
    end

    def generate_slots(date, working_range, booked_ranges)
      slots = []
      timezone = @professional.account.timezone
      zone = ActiveSupport::TimeZone[timezone]

      slot_start = zone.local(date.year, date.month, date.day,
                              working_range[:starts_at].hour,
                              working_range[:starts_at].min)
      work_end = zone.local(date.year, date.month, date.day,
                            working_range[:ends_at].hour,
                            working_range[:ends_at].min)

      while slot_start + @duration.minutes <= work_end
        slot_end = slot_start + @duration.minutes

        unless overlaps_any?(slot_start, slot_end, booked_ranges)
          slots << TimeSlot.new(starts_at: slot_start, ends_at: slot_end)
        end

        slot_start = slot_end + @buffer_minutes.minutes
      end

      slots
    end

    def overlaps_any?(slot_start, slot_end, booked_ranges)
      booked_ranges.any? do |booked|
        slot_start < booked[:ends_at] && slot_end > booked[:starts_at]
      end
    end
  end
end
