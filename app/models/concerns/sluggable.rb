# frozen_string_literal: true

# Sluggable concern — generates URL-safe slugs from a source attribute.
# Usage: include Sluggable in a model that has a `slug` column.
#        Set `slug_source` to the attribute used to generate the slug.
module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, on: :create

    validates :slug, presence: true, uniqueness: true,
              format: { with: /\A[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\z/,
                         message: "deve conter apenas letras minúsculas, números e hífens" }
  end

  class_methods do
    def slug_source(attribute = nil)
      if attribute
        @slug_source = attribute
      else
        @slug_source || :name
      end
    end
  end

  private

  def generate_slug
    return if slug.present?

    base_slug = send(self.class.slug_source).to_s.parameterize
    candidate = base_slug
    counter = 1

    while self.class.exists?(slug: candidate)
      candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = candidate
  end
end
