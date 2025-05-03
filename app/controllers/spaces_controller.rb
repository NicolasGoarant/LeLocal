require 'ostruct'

class SpacesController < ApplicationController
  before_action :set_space, only: [:show, :edit, :update, :destroy]
  
  def index
    @spaces = Space.all
    # Combiner les espaces de la BD avec les espaces simulés
    @spaces = (@spaces + simulated_spaces).sort_by(&:created_at).reverse
  end
  
  def show
    id = params[:id]
    space_name = params[:space_name]

    # Si l'espace n'est pas encore défini par le before_action set_space
    unless @space
      # Pour les IDs négatifs (espaces simulés), nous utilisons notre logique personnalisée
      if id.to_i < 0
        # Essayer de trouver l'espace simulé par ID
        @space = get_simulated_space_by_id(id.to_i)
        
        # Si l'espace n'est pas trouvé mais que le nom est fourni, essayer de le trouver par nom
        if @space.nil? && space_name.present?
          @space = get_simulated_space_by_name(space_name)
        end
      else
        # Pour les IDs positifs, rechercher dans la base de données
        @space = Space.find_by(id: id)
      end
    end

    # Si aucun espace n'est trouvé, rediriger vers la recherche
    unless @space
      flash[:alert] = "L'espace demandé n'a pas été trouvé."
      redirect_to search_spaces_path and return
    end

    # Préparer les données pour la carte
    @marker = {
      lat: @space.latitude,
      lng: @space.longitude,
      info: @space.name,
      id: @space.id
    }
  end
  
  def new
    @space = Space.new
  end
  
  def create
    @space = Space.new(space_params)
    @space.user = current_user if user_signed_in?
    
    if @space.save
      flash[:notice] = "Votre espace a été créé avec succès et sera vérifié par notre équipe."
      redirect_to @space
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @space.update(space_params)
      flash[:notice] = "Les informations de l'espace ont été mises à jour."
      redirect_to @space
    else
      render :edit
    end
  end
  
  def destroy
    @space.destroy
    flash[:notice] = "L'espace a été supprimé."
    redirect_to spaces_path
  end
  
  def search
    @location = params[:location]
    @date = params[:date]
    @start_time = params[:start_time]
    @end_time = params[:end_time]
    @capacity = params[:capacity]
    @category = params[:category]
    @sort = params[:sort] || 'rating'
    
    # Convertir la capacité en nombre
    if @capacity.present?
      if @capacity.include?("-")
        min_capacity, max_capacity = @capacity.split("-").map(&:to_i)
        @capacity_filter = "#{min_capacity}-#{max_capacity} personnes"
      else
        min_capacity = @capacity.to_i
        @capacity_filter = "#{min_capacity}+ personnes"
      end
    end
    
    # Initialiser les espaces
    @spaces = []
    
    # Simuler la recherche par ville
    if @location.present?
      @spaces = simulated_spaces_by_city(@location)
      
      # Définir les coordonnées du centre de la carte
      @center_coords = city_coordinates(@location)
    else
      @spaces = simulated_spaces
    end
    
    # Filtrer par catégorie si spécifiée
    if @category.present? && @category != "Toutes les catégories"
      @spaces = @spaces.select { |s| s.category == @category }
    end
    
    # Filtrer par capacité si spécifiée
    if @capacity.present?
      if @capacity.include?("-")
        min_capacity, max_capacity = @capacity.split("-").map(&:to_i)
        @spaces = @spaces.select { |s| s.capacity >= min_capacity && s.capacity <= max_capacity }
      else
        min_capacity = @capacity.to_i
        @spaces = @spaces.select { |s| s.capacity >= min_capacity }
      end
    end
    
    # Trier les espaces
    case @sort
    when 'price_asc'
      @spaces.sort_by!(&:price_per_hour)
    when 'price_desc'
      @spaces.sort_by!(&:price_per_hour).reverse!
    when 'capacity'
      @spaces.sort_by!(&:capacity).reverse!
    else
      @spaces.sort_by!(&:rating).reverse!
    end
  end
  
  def new_host
    # Page de présentation pour les hôtes
  end
  
  private
  
  def set_space
    # Essayer de trouver un espace standard d'abord (avec ID positif)
    if params[:id].to_i > 0
      @space = Space.find_by(id: params[:id])
    else
      # Pour les IDs négatifs, trouver parmi les espaces simulés
      @space = get_simulated_space_by_id(params[:id].to_i)
    end
  end
  
  def space_params
    params.require(:space).permit(:name, :description, :address, :city, :capacity, 
                                  :price_per_hour, :category, :rules, :cancellation_policy,
                                  :amenities => [])
  end
  
  # Méthode pour obtenir un espace simulé par ID
  def get_simulated_space_by_id(id)
    simulated_spaces.find { |space| space.id == id }
  end
  
  # Méthode pour obtenir un espace simulé par nom
  def get_simulated_space_by_name(name)
    simulated_spaces.find { |space| space.name == name }
  end
  
  # Méthode pour générer les espaces simulés
  def simulated_spaces
    all_spaces = []
    
    # Ajouter les espaces de différentes villes
    all_spaces += simulated_spaces_by_city("Paris")
    all_spaces += simulated_spaces_by_city("Lyon")
    all_spaces += simulated_spaces_by_city("Nancy")
    all_spaces += simulated_spaces_by_city("Bordeaux")
    all_spaces += simulated_spaces_by_city("Lille")
    
    all_spaces
  end
  
  def simulated_spaces_by_city(city)
    spaces = []
    
    case city.downcase
    when "paris"
      # Espaces à Paris
      spaces << OpenStruct.new(
        id: -1,
        name: "Studio Photo Montmartre",
        description: "Espace idéal pour les séances photos et petits tournages, situé au cœur de Montmartre. Équipement professionnel disponible sur demande.",
        address: "15 Rue des Abbesses, 75018 Paris",
        city: "Paris",
        capacity: 15,
        price_per_hour: 35,
        rating: 4.8,
        category: "Espace événementiel",
        amenities: ["WiFi", "Équipement audio", "Éclairage", "Prises multiples"],
        rules: "Pas de nourriture ni boisson près des équipements. Nettoyage obligatoire.",
        cancellation_policy: "Remboursement à 100% si annulation 72h avant.",
        latitude: 48.8843,
        longitude: 2.3378
      )
      
      spaces << OpenStruct.new(
        id: -2,
        name: "Salle de Réunion République",
        description: "Salle de réunion professionnelle à deux pas de la place de la République, équipée pour vos présentations et conférences.",
        address: "8 Rue du Château d'Eau, 75010 Paris",
        city: "Paris",
        capacity: 25,
        price_per_hour: 45,
        rating: 4.5,
        category: "Salle de réunion",
        amenities: ["WiFi", "Vidéoprojecteur", "Tableau blanc", "Eau", "Café"],
        rules: "Uniquement réservé aux réunions professionnelles.",
        cancellation_policy: "Remboursement à 50% si annulation 48h avant.",
        latitude: 48.8701,
        longitude: 2.3631
      )
      
    when "lyon"
      # Espaces à Lyon
      spaces << OpenStruct.new(
        id: -3,
        name: "Espace Créatif Croix-Rousse",
        description: "Atelier lumineux situé dans le quartier de la Croix-Rousse, parfait pour les activités créatives et les ateliers participatifs.",
        address: "12 Rue Pailleron, 69004 Lyon",
        city: "Lyon",
        capacity: 18,
        price_per_hour: 30,
        rating: 4.7,
        category: "Atelier",
        amenities: ["WiFi", "Tables de travail", "Matériel créatif", "Cuisine"],
        rules: "Respect des lieux et nettoyage après usage.",
        cancellation_policy: "Remboursement à 100% si annulation 48h avant.",
        latitude: 45.7741,
        longitude: 4.8284
      )
      
    when "nancy"
      # Espaces à Nancy
      spaces << OpenStruct.new(
        id: -4,
        name: "Espace Coworking Centre",
        description: "Espace de travail partagé en plein centre-ville, adapté pour les associations et les entrepreneurs.",
        address: "15 Rue Saint-Dizier, 54000 Nancy",
        city: "Nancy",
        capacity: 10,
        price_per_hour: 20,
        rating: 4.3,
        category: "Bureau partagé",
        amenities: ["WiFi", "Imprimante", "Cuisine partagée", "Café", "Eau"],
        rules: "Respect du calme pour tous les coworkers.",
        cancellation_policy: "Remboursement à 100% si annulation 24h avant.",
        latitude: 48.6921,
        longitude: 6.1844
      )
      
      spaces << OpenStruct.new(
        id: -5,
        name: "Salle Polyvalente Pépinière",
        description: "Grande salle adaptée à tous types d'événements associatifs dans le quartier de la Pépinière.",
        address: "42 Rue de la Pépinière, 54000 Nancy",
        city: "Nancy",
        capacity: 50,
        price_per_hour: 60,
        rating: 4.6,
        category: "Espace événementiel",
        amenities: ["WiFi", "Système de son", "Tables et chaises", "Cuisine", "Parking"],
        rules: "Interdiction de fumer. Nettoyage à la charge du réservant.",
        cancellation_policy: "Remboursement à 50% si annulation 72h avant.",
        latitude: 48.6840,
        longitude: 6.1746
      )
      
    when "bordeaux"
      # Espaces à Bordeaux
      spaces << OpenStruct.new(
        id: -6,
        name: "Salle des Chartrons",
        description: "Belle salle de conférence dans le quartier des Chartrons, parfaite pour les événements culturels et professionnels.",
        address: "23 Rue Notre Dame, 33000 Bordeaux",
        city: "Bordeaux",
        capacity: 35,
        price_per_hour: 50,
        rating: 4.9,
        category: "Salle de réunion",
        amenities: ["WiFi", "Vidéoprojecteur", "Sonorisation", "Climatisation"],
        rules: "Événements culturels prioritaires. Pas de musique après 22h.",
        cancellation_policy: "Remboursement à 70% si annulation 72h avant.",
        latitude: 44.8511,
        longitude: -0.5689
      )
      
    when "lille"
      # Espaces à Lille
      spaces << OpenStruct.new(
        id: -7,
        name: "Studio Danse Vieux-Lille",
        description: "Studio de danse professionnel dans le Vieux-Lille, équipé de miroirs et d'un système audio de qualité.",
        address: "18 Rue de la Monnaie, 59000 Lille",
        city: "Lille",
        capacity: 20,
        price_per_hour: 40,
        rating: 4.7,
        category: "Salle de sport",
        amenities: ["Miroirs", "Système audio", "Vestiaires", "Douches"],
        rules: "Chaussures de danse obligatoires. Respect des horaires.",
        cancellation_policy: "Remboursement à 50% si annulation 48h avant.",
        latitude: 50.6387,
        longitude: 3.0639
      )
    end
    
    spaces
  end
  
  def city_coordinates(city)
    case city.downcase
    when "paris"
      [48.8566, 2.3522]
    when "lyon"
      [45.7578, 4.8320]
    when "nancy"
      [48.6921, 6.1844]
    when "bordeaux"
      [44.8378, -0.5792]
    when "lille"
      [50.6292, 3.0573]
    else
      [46.603354, 1.888334] # Centre de la France
    end
  end
end