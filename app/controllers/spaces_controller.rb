class SpacesController < ApplicationController
  before_action :set_space, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!, except: [:index, :show, :search] # À décommenter quand vous intégrerez Devise

  # GET /spaces
  def index
    @spaces = Space.all
    
    # Filtrage par catégorie si spécifié
    @spaces = @spaces.where(category: params[:category]) if params[:category].present?
    
    # Tri des résultats
    case params[:sort]
    when 'price_asc'
      @spaces = @spaces.order(price_per_hour: :asc)
    when 'price_desc'
      @spaces = @spaces.order(price_per_hour: :desc)
    when 'rating'
      @spaces = @spaces.order(rating: :desc)
    when 'capacity'
      @spaces = @spaces.order(capacity: :desc)
    else
      @spaces = @spaces.order(created_at: :desc) # Par défaut, les plus récents d'abord
    end
    
    # Préparer les données pour la carte
    @markers = @spaces.map do |space|
      {
        lat: space.latitude,
        lng: space.longitude,
        info: space.name,
        id: space.id
      }
    end
  end

  # GET /spaces/1
  def show
    # Préparer les données pour les réservations
    @booking = Booking.new if defined?(Booking)
    
    # Récupérer les avis/évaluations
    @reviews = @space.reviews if @space.respond_to?(:reviews)
    
    # Préparer les données pour la carte
    @marker = {
      lat: @space.latitude,
      lng: @space.longitude,
      info: @space.name,
      id: @space.id
    }
  end

  # GET /spaces/new
  def new
    @space = Space.new
  end

  # GET /spaces/new_host
  def new_host
    @space = Space.new
    render :new_host
  end

  # GET /spaces/1/edit
  def edit
  end

  # POST /spaces
  def create
    @space = Space.new(space_params)
    # @space.user = current_user # À décommenter quand vous intégrerez Devise

    if @space.save
      redirect_to @space, notice: 'Espace créé avec succès.'
    else
      render :new
    end
  end

  # PATCH/PUT /spaces/1
  def update
    if @space.update(space_params)
      redirect_to @space, notice: 'Espace mis à jour avec succès.'
    else
      render :edit
    end
  end

  # DELETE /spaces/1
  def destroy
    @space.destroy
    redirect_to spaces_url, notice: 'Espace supprimé avec succès.'
  end

  # GET /spaces/search
  def search
  @location = params[:location]
  @date = params[:date]
  @start_time = params[:start_time]
  @end_time = params[:end_time]
  @capacity = params[:capacity]
  
  # Décommenter cette ligne si vous voulez voir les paramètres dans les logs
  # Rails.logger.info "Search params: #{params.inspect}"
  
  @spaces = []

  # Votre code pour les villes
  city_data = case @location.downcase
  when "paris", "paris "
    {
      name: "Paris",
      base_coords: [48.856614, 2.3522219],
      spaces: [
        { name: "Atelier Créatif Bastille", description: "Grand espace lumineux idéal pour ateliers créatifs et réunions.", address: "12 Rue de la Roquette, 75011 Paris", capacity: 25, price_per_hour: 35, category: "creative_studio", rating: 4.8 },
        { name: "Espace Coworking République", description: "Espace de coworking moderne en plein cœur de Paris.", address: "8 Place de la République, 75003 Paris", capacity: 15, price_per_hour: 28, category: "coworking", rating: 4.5 },
        { name: "Salle de Réunion Marais", description: "Salle de réunion équipée dans le quartier du Marais.", address: "25 Rue des Archives, 75004 Paris", capacity: 8, price_per_hour: 45, category: "meeting_room", rating: 4.2 }
      ]
    }
  when "lyon", "lyon "
    {
      name: "Lyon",
      base_coords: [45.764043, 4.835659],
      spaces: [
        { name: "Espace Confluence", description: "Espace modulable dans le quartier de Confluence.", address: "15 Cours Charlemagne, 69002 Lyon", capacity: 35, price_per_hour: 40, category: "event_space", rating: 4.6 },
        { name: "Atelier des Canuts", description: "Ancien atelier rénové dans le quartier de la Croix-Rousse.", address: "10 Rue d'Ivry, 69004 Lyon", capacity: 18, price_per_hour: 32, category: "creative_studio", rating: 4.7 },
        { name: "Bureau Part-Dieu", description: "Bureau tout équipé à proximité de la gare.", address: "129 Rue Servient, 69003 Lyon", capacity: 6, price_per_hour: 25, category: "meeting_room", rating: 4.3 }
      ]
    }
  when "nancy", "nancy "
    # Données pour Nancy
    {
      name: "Nancy",
      base_coords: [48.6921, 6.1844],
      spaces: [
        { name: "Espace Stanislas", description: "Belle salle dans un bâtiment historique près de la Place Stanislas.", address: "5 Rue Stanislas, 54000 Nancy", capacity: 20, price_per_hour: 30, category: "event_space", rating: 4.5 },
        { name: "Atelier Art Nouveau", description: "Espace inspirant dans un style Art Nouveau.", address: "12 Rue Émile Gallé, 54000 Nancy", capacity: 15, price_per_hour: 28, category: "creative_studio", rating: 4.6 },
        { name: "Salle de Formation Pépinière", description: "Salle moderne pour formations et workshops.", address: "3 Rue Victor, 54000 Nancy", capacity: 12, price_per_hour: 25, category: "training_room", rating: 4.4 }
      ]
    }
  when "bordeaux", "bordeaux "
    # Données pour Bordeaux
    {
      name: "Bordeaux",
      base_coords: [44.8378, -0.5792],
      spaces: [
        { name: "Loft des Chartrons", description: "Loft industriel dans le quartier des Chartrons.", address: "15 Rue Notre Dame, 33000 Bordeaux", capacity: 25, price_per_hour: 35, category: "event_space", rating: 4.7 },
        { name: "Espace Saint-Pierre", description: "Salle élégante au cœur du vieux Bordeaux.", address: "8 Place Saint-Pierre, 33000 Bordeaux", capacity: 18, price_per_hour: 40, category: "meeting_room", rating: 4.6 },
        { name: "Studio Quai des Marques", description: "Studio créatif avec vue sur la Garonne.", address: "20 Quai des Marques, 33000 Bordeaux", capacity: 15, price_per_hour: 30, category: "creative_studio", rating: 4.5 }
      ]
    }
  when "lille", "lille "
    # Données pour Lille
    {
      name: "Lille",
      base_coords: [50.6292, 3.0573],
      spaces: [
        { name: "Studio Vieux-Lille", description: "Charmant studio dans le Vieux-Lille.", address: "12 Rue de la Monnaie, 59000 Lille", capacity: 15, price_per_hour: 28, category: "creative_studio", rating: 4.5 },
        { name: "Salle Euralille", description: "Salle moderne près du centre commercial Euralille.", address: "5 Avenue Willy Brandt, 59000 Lille", capacity: 20, price_per_hour: 32, category: "meeting_room", rating: 4.3 },
        { name: "Espace Coworking Gare", description: "Espace de coworking à 5 minutes de la gare Lille Flandres.", address: "23 Place des Buisses, 59000 Lille", capacity: 10, price_per_hour: 25, category: "coworking", rating: 4.4 }
      ]
    }
  else
    nil
  end

  if city_data.present?
    @city = city_data[:name]
    @center_coords = city_data[:base_coords]

    # ICI EST LA CORRECTION - Créer des objets Space sans passer par sérialisation/désérialisation
    city_data[:spaces].each_with_index do |space_data, index|
      space = Space.new
      space.name = space_data[:name]
      space.description = space_data[:description]
      space.address = space_data[:address]
      space.capacity = space_data[:capacity]
      space.price_per_hour = space_data[:price_per_hour]
      space.category = space_data[:category]
      space.rating = space_data[:rating]
      
      # Utilisation de faux ID temporaires (toujours négatifs pour éviter les conflits avec de vrais IDs)
      space.id = -(index + 1)
      
      # Coordonnées légèrement modifiées pour la visualisation
      space.latitude = city_data[:base_coords][0] + (index * 0.005)
      space.longitude = city_data[:base_coords][1] + (index * 0.005)
      
      @spaces << space
    end
  else
    @city = nil
    @center_coords = nil
  end

  # Filtrer par capacité si spécifié
  if @capacity.present?
    capacity_range = case @capacity
      when "1-10 personnes" then [1, 10]
      when "11-30 personnes" then [11, 30]
      when "31-50 personnes" then [31, 50]
      when "Plus de 50 personnes" then [51, nil]
      else nil
    end
    
    @spaces = @spaces.select { |space| 
      if capacity_range[1].nil?
        space.capacity >= capacity_range[0]
      else
        space.capacity >= capacity_range[0] && space.capacity <= capacity_range[1]
      end
    } if capacity_range
  end
  
  render :search
end

  private
    # Récupérer l'espace par son ID
    def set_space
      @space = Space.find(params[:id])
    end

    # Paramètres autorisés
    def space_params
      params.require(:space).permit(
        :name, 
        :description, 
        :address, 
        :capacity, 
        :price_per_hour, 
        :category, 
        :images,
        :latitude,
        :longitude
      )
    end
end