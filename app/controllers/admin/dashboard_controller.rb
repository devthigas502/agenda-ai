# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @today_bookings = current_tenant.bookings.for_date(Date.current).order(starts_at: :asc)
      @upcoming_bookings = current_tenant.bookings.upcoming.limit(5)
      @total_bookings_count = current_tenant.bookings.count
      @completed_count = current_tenant.bookings.by_status("completed").count
      @cancelled_count = current_tenant.bookings.by_status("cancelled").count
      @no_show_count = current_tenant.bookings.by_status("no_show").count
      @estimated_revenue = current_tenant.bookings.where(status: %w[confirmed completed]).sum(:price_cents) / 100.0
      @professionals_count = current_tenant.professionals.active.count
      @services_count = current_tenant.services.active.count
    end
  end
end
