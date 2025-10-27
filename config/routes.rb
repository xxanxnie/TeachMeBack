# config/routes.rb
Rails.application.routes.draw do
  root "home#index"
  get "/dashboard", to: "dashboard#index"

  resources :skill_exchange_requests, only: [:new, :create, :show]

  get    "/signup", to: "users#new"
  post   "/users",  to: "users#create"
  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
end
