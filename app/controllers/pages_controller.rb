# frozen_string_literal: true

class PagesController < ApplicationController
  def landing
    redirect_to admin_root_path if user_signed_in?
  end
end
