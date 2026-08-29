# frozen_string_literal: true

# Sortable concern — provides position-based ordering.
module Sortable
  extend ActiveSupport::Concern

  included do
    scope :sorted, -> { order(position: :asc) }
  end
end
