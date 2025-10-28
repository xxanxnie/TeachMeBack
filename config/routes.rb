Rails.application.routes.draw do
  # Root route
  root 'sessions#new'

  # Core pages
  get '/dashboard', to: 'dashboard#index'
  get '/match', to: 'match#index'
  get '/explore', to: 'explore#index'

  # Skill exchange request routes
  resources :skill_exchange_requests, only: [:new, :create, :show]
  get '/requests', to: 'skill_exchange_requests#index'

  # Authentication routes
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # User routes
  get '/signup', to: 'users#new'
  post '/users', to: 'users#create'
  get '/profile', to: 'users#edit'
end
