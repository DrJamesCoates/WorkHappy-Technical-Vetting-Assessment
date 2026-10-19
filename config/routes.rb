Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get    "login",  to: "sessions#new"
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :assessments, only: :index do
    get :export, on: :collection
  end
  root "assessments#index"
end
