Rails.application.routes.draw do
  # Besoins (form + page carte)
  get 'needs', to: redirect('/needs/new')
  resources :needs, only: [:new, :create, :show] do
    collection { get :map }   # => map_needs_path
  end

  # Page d'accueil
  root 'home#index'

  # Auth Devise
  devise_for :users, controllers: { registrations: 'registrations' }
  get '/signup', to: 'registrations#new', as: :signup

  # Espaces
  resources :spaces do
    collection do
      get  'map'
      get  'new_host'
      post 'submit_host'
    end
    member do
      get  'reserve'
      post 'book'
    end
  end

  # Pages statiques
  get 'about',   to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'
  get 'terms',   to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  get 'faq',     to: 'static_pages#faq'

  # Réservations
  resources :bookings do
    member do
      patch 'confirm'
      patch 'cancel'
      patch 'complete'
    end
  end

  # Avis
  resources :reviews, only: [:create, :edit, :update, :destroy]

  # Recherche
  get 'search', to: 'search#index'

  # Profil
  resource :profile, only: [:show, :edit, :update]

  # Dashboard
  namespace :dashboard do
    root to: 'overview#index'
    resources :spaces
    resources :needs, only: [:new, :create]
    resources :bookings
    resources :notifications, only: [:index, :show, :update]
  end

  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :spaces, only: [:index, :show]
      resources :needs,  only: [:new, :create, :show]
    end
  end
end
