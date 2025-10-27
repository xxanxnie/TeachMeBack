# config/routes.rb
Rails.application.routes.draw do
  get "dashboard", to: "dashboard#index"
  root "dashboard#index"
  resources :skill_exchange_requests, only: [:new, :create, :show]
end
