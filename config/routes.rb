Rails.application.routes.draw do
  get "needs/index"
  get "needs/new"
  get "needs/create"
  get "needs/show"
  # Page d'accueil
  root 'home#index'
  
  # Routes pour les espaces
  resources :spaces do
    collection do
      get 'search'  # Route pour la recherche des espaces
      get 'new_host' # Route pour "Proposer un espace"
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
  resources :needs, only: [:index, :new, :create, :show]

  # Route pour la newsletter
  post '/newsletter', to: 'newsletters#create'
  
  # Routes pour les pages statiques
  get '/about', to: 'pages#about'
  get '/how-it-works', to: 'pages#how_it_works'
  get '/faq', to: 'pages#faq'
  get '/contact', to: 'pages#contact'
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'
    
  # Route pour les besoins des associations
  resources :needs, only: [:index, :show, :new, :create]
  
  # Route de profile utilisateur (si vous n'utilisez pas Devise)
  # get '/profile', to: 'users#show'
  # get '/profile/edit', to: 'users#edit'
  # patch '/profile', to: 'users#update'

  devise_for :users, controllers: {
  registrations: 'registrations'
}

# Route directe vers la page d'inscription
get '/inscription', to: 'registrations#new', as: 'signup'

end