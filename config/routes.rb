Rails.application.routes.draw do
  # Root route
  root 'home#index'

  # Core pages
  get '/explore', to: 'explore#index'
  get '/match', to: 'match#index'

  # Skill exchange request routes
  resources :skill_exchange_requests do
    post :express_interest, on: :member
  end
  get '/requests', to: 'skill_exchange_requests#index'

  resources :user_skill_requests, only: [:create]

  # Authentication routes
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  match '/logout', to: 'sessions#destroy', via: [:get, :delete], as: 'logout'

  # User routes
  get '/signup', to: 'users#new'
  post '/users', to: 'users#create'
  get '/profile', to: 'users#edit'
  patch '/profile', to: 'users#update'

  # Messaging routes (safe, query-param based)
  resources :messages, only: [:index, :new, :create]
  get 'messages/thread', to: 'messages#thread', as: :message_thread
end
