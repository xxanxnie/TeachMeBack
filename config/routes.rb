# config/routes.rb
Rails.application.routes.draw do
  root "home#index"

  get  "/signup",   to: "users#new"
  post "/users",    to: "users#create"

  get    "/login",  to: "sessions#new"
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  # Minimal dashboard path to satisfy the Cucumber step
  get "/dashboard", to: "home#index"
end

