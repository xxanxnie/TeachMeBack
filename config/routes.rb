# config/routes.rb
Rails.application.routes.draw do
  resources :skill_exchange_requests, only: [:new, :create, :show]
end
