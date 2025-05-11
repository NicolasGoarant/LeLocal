Rails.application.routes.draw do
  # Page d'accueil
  root 'home#index'
  
  # Routes pour l'authentification via Devise
  devise_for :users
  
  # Routes pour les espaces
  resources :spaces do
    collection do
      get 'map'
      get 'new_host' # Route pour les hôtes proposant un espace
    end
    member do
      get 'reserve'
      post 'book'
    end
  end
  
  # Routes pour les besoins
  resources :needs do
    collection do
      get 'map'
    end
    member do
      get 'propose'
      post 'offer'
    end
  end
  
  # Routes statiques
  get 'about', to: 'static_pages#about'
  get 'contact', to: 'static_pages#contact'
  get 'terms', to: 'static_pages#terms'
  get 'privacy', to: 'static_pages#privacy'
  get 'faq', to: 'static_pages#faq'
  
  # Routes pour les réservations
  resources :bookings do
    member do
      patch 'confirm'
      patch 'cancel'
      patch 'complete'
    end
  end
  
  # Routes pour les avis
  resources :reviews, only: [:create, :edit, :update, :destroy]
  
  # Routes pour la recherche
  get 'search', to: 'search#index'
  
  # Routes pour le profil utilisateur
  resource :profile, only: [:show, :edit, :update]
  
  # Dashboard
  namespace :dashboard do
    root to: 'overview#index'
    resources :spaces
    resources :needs
    resources :bookings
    resources :notifications, only: [:index, :show, :update]
  end
  
  # API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :spaces, only: [:index, :show]
      resources :needs, only: [:index, :show]
    end
  end
end