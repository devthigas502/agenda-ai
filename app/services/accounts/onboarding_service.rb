# frozen_string_literal: true

module Accounts
  class OnboardingService
    include ActiveModel::Model

    def self.model_name
      ActiveModel::Name.new(self, nil, "Onboarding")
    end

    attr_accessor :account_name, :user_name, :email, :phone, :password, :password_confirmation
    attr_reader :account, :user

    def initialize(params = {})
      return if params.blank?

      @account_name = params[:account_name]
      @user_name = params[:user_name]
      @email = params[:email]
      @phone = params[:phone]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
    end

    def call
      ActiveRecord::Base.transaction do
        create_account!
        create_user!
      end

      self
    rescue ActiveRecord::RecordInvalid => e
      e.record.errors.each do |err|
        errors.add(:base, err.full_message)
      end
      self
    end

    def success?
      errors.empty? && account&.persisted? && user&.persisted?
    end

    private

    def create_account!
      @account = Account.create!(
        name: @account_name,
        email: @email,
        phone: @phone
      )
    end

    def create_user!
      @user = User.create!(
        account: @account,
        name: @user_name,
        email: @email,
        password: @password,
        password_confirmation: @password_confirmation,
        role: "owner"
      )
    end
  end
end
