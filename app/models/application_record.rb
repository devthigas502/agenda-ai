class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  before_create :ensure_uuid

  private

  def ensure_uuid
    self.id ||= SecureRandom.uuid if self.class.primary_key == "id" && respond_to?(:id=)
  end
end
