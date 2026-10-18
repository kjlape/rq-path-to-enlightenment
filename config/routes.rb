Rails.application.routes.draw do
  get "settings", to: "settings#index"
  resources :challenge_answers

  resources :journeys do
    resources :challenges, shallow: true
  end

  resources :minitest_test_classes, shallow: true do
    resources :minitest_test_methods
  end

  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  resources :sessions, only: [:index, :show, :destroy]
  resource :password, only: [:edit, :update]
  namespace :identity do
    resource :email, only: [:edit, :update]
    resource :email_verification, only: [:show, :create]
    resource :password_reset, only: [:new, :edit, :create, :update]
  end
  namespace :two_factor_authentication do
    namespace :challenge do
      resource :totp, only: [:new, :create]
      resource :recovery_codes, only: [:new, :create]
    end
    namespace :profile do
      resource :totp, only: [:new, :create, :update]
      resources :recovery_codes, only: [:index, :create]
    end
  end
  get "/auth/failure", to: "sessions/omniauth#failure"
  get "/auth/:provider/callback", to: "sessions/omniauth#create"
  post "/auth/:provider/callback", to: "sessions/omniauth#create"
  namespace :sessions do
    resource :sudo, only: [:new, :create]
  end
  root "home#index"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check
end
