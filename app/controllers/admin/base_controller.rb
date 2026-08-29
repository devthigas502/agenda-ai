# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    set_current_tenant_through_filter
    before_action :set_tenant

    layout "admin"

    private

    def set_tenant
      set_current_tenant(current_user.account)
    end
  end
end
