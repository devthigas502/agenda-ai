# frozen_string_literal: true

module Public
  class BaseController < ApplicationController
    set_current_tenant_through_filter
    before_action :set_tenant_by_slug

    layout "public"

    private

    def set_tenant_by_slug
      @account = Account.find_by!(slug: params[:slug])
      set_current_tenant(@account)
    end
  end
end
