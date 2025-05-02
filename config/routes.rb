Rails.application.routes.draw do
  # Page d'accueil
  root 'home#index'
  
  # Routes pour les espaces
  resources :spaces do
    collection do
      get 'search'  # Route pour la recherche des espaces
    end
    
    # Routes imbriquées pour les réservations d'un espace spécifique
    resources :bookings, only: [:new, :create]
    
    # Routes imbriquées pour les avis/reviews d'un espace
    resources :reviews, only: [:new, :create]
  end
  
  # Routes pour les catégories
  resources :categories, only: [:index, :show]
  
  # Routes pour les réservations (sauf new et create qui sont imbriquées)
  resources :bookings, except: [:new, :create]
  
  # Routes pour le profil utilisateur (si vous utilisez Devise)
  # devise_for :users
  
  # Route pour la newsletter
  post '/newsletter', to: 'newsletters#create'
  
  # Routes pour les pages statiques
  get '/about', to: 'pages#about'
  get '/how-it-works', to: 'pages#how_it_works'
  get '/faq', to: 'pages#faq'
  get '/contact', to: 'pages#contact'
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'
  
  # Route de profile utilisateur (si vous n'utilisez pas Devise)
  # get '/profile', to: 'users#show'
  # get '/profile/edit', to: 'users#edit'
  # patch '/profile', to: 'users#update'
end