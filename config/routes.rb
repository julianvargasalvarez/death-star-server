Rails.application.routes.draw do
  resources :battles, only: :show do
    get '/faucet', to: 'battles/faucet#index'
    post '/supersecreto', to: 'battles/faucet#create'
  end
  resources :teams, only: :create
  put '/teams', to: 'teams#update'
  root to: 'home#index'
end
