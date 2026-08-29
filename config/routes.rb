# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  # Custom onboarding registration
  get "/signup", to: "registrations#new", as: :new_user_registration
  post "/signup", to: "registrations#create", as: :user_registration

  # Admin Namespace (Authenticated)
  namespace :admin do
    root to: "dashboard#index"

    resources :professionals do
      resources :schedules, only: [:index, :create, :destroy]
    end

    resources :services
    resources :bookings do
      member do
        patch :confirm
        patch :complete
        patch :cancel
        patch :no_show
      end
    end
    resources :clients, only: [:index, :show]
    resource :settings, only: [:show, :update]

    resource :subscription, only: [:show, :create] do
      post :portal
      get :success
      get :cancel
    end
  end

  # Stripe Webhook
  post "/webhooks/stripe", to: "webhooks/stripe#create"

  # API Namespace (v1)
  namespace :api do
    namespace :v1 do
      post "auth/token", to: "auth_tokens#create"
      resources :services, only: [:create]
    end
  end


  # Public Booking Page (Scoped by account slug)
  scope "/:slug" do
    get "/", to: "public/booking_pages#show", as: :public_booking_page
    get "/slots", to: "public/booking_pages#slots", as: :public_booking_slots
    post "/book", to: "public/bookings#create", as: :public_bookings
    get "/confirmation/:id", to: "public/bookings#confirmation", as: :public_booking_confirmation
  end

  root to: "pages#landing"
end
