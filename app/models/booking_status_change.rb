# frozen_string_literal: true

class BookingStatusChange < ApplicationRecord
  belongs_to :booking

  validates :to_status, presence: true
end
