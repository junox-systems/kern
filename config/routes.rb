Rails.application.routes.draw do
  # The home screen — attention allocation
  root "dashboard#show"
  resource :dashboard, only: :show, controller: "dashboard"

  # Commitment lifecycle
  resources :commitments do
    member do
      post :complete
      post :defer
      post :archive
    end
  end

  # Inbox triage
  resource :inbox, only: :show, controller: "inbox"

  # Configuration
  resources :categories
  resources :calendar_blocks

  # Authentication
  resource :session
  resource :registration, only: %i[new create]
  resource :profile, only: %i[show update]
  resources :passwords, param: :token

  # Health
  get "up" => "rails/health#show", as: :rails_health_check
end
