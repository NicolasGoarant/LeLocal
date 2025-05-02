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
    @capacity_filter = params[:capacity]
    @sort = params[:sort] || "rating"
    
    # Construire la requête de base
    @spaces = Space.all
    
    # Recherche plus flexible par emplacement
    if @location.present?
      location_query = "%#{@location.downcase}%"
      @spaces = @spaces.where("LOWER(address) LIKE ? OR LOWER(name) LIKE ?", location_query, location_query)
    end
    
    # Filtrer par capacité si spécifiée
    if @capacity_filter.present?
      capacity_range = case @capacity_filter
                     when "1-10 personnes" then 1..10
                     when "11-30 personnes" then 11..30
                     when "31-50 personnes" then 31..50
                     when "Plus de 50 personnes" then 51..1000
                     else nil
                     end
      @spaces = @spaces.where(capacity: capacity_range) if capacity_range
    end
    
    # Filtrer par date et horaire si spécifiés
    # Note: Cette partie dépend de votre structure de réservations
    if @date.present? && @start_time.present? && @end_time.present?
      # Convertir les chaînes en objets Time pour comparaison
      day_date = Date.parse(@date) rescue nil
      
      if day_date && defined?(Booking)
        # Trouver les IDs des espaces qui ont déjà des réservations pour cette période
        booking_start = Time.parse("#{@date} #{@start_time}") rescue nil
        booking_end = Time.parse("#{@date} #{@end_time}") rescue nil
        
        if booking_start && booking_end
          booked_space_ids = Booking.where(date: day_date)
                                  .where("(start_time <= ? AND end_time > ?) OR (start_time < ? AND end_time >= ?) OR (start_time >= ? AND end_time <= ?)", 
                                        booking_end, booking_start, booking_end, booking_start, booking_start, booking_end)
                                  .pluck(:space_id)
          
          # Exclure les espaces déjà réservés
          @spaces = @spaces.where.not(id: booked_space_ids) if booked_space_ids.any?
        end
      end
    end
    
    # Trier les résultats
    case @sort
    when "price_asc"
      @spaces = @spaces.order(price_per_hour: :asc)
    when "price_desc"
      @spaces = @spaces.order(price_per_hour: :desc)
    when "capacity"
      @spaces = @spaces.order(capacity: :desc)
    else
      @spaces = @spaces.order(rating: :desc) # Par défaut, trier par évaluation
    end
    
    # Si aucun espace n'est trouvé, mais que nous avons un emplacement,
    # créer des exemples temporaires pour les villes majeures
    if @spaces.empty? && @location.present?
      # Créer des exemples pour les villes principales
      example_spaces = []
      
      # Coordonnées par défaut pour quelques villes françaises majeures
      cities_data = {
        "paris" => {
          base_coords: [48.8566, 2.3522],
          spaces: [
            {
              name: "Espace Créatif Montmartre",
              description: "Espace lumineux au cœur de Montmartre, idéal pour les réunions créatives et ateliers artistiques. Grande verrière, équipement audio-visuel complet et coin détente inclus.",
              address: "18 Rue des Abbesses, Paris 18ème",
              capacity: 25,
              price_per_hour: 45,
              rating: 4.8,
              images: "https://images.unsplash.com/photo-1497366754035-f200968a6e72",
              category: "Ateliers créatifs"
            },
            {
              name: "Salle Panoramique République",
              description: "Grande salle avec vue panoramique sur la place de la République. Équipement audiovisuel haut de gamme, grande table modulable et cuisine attenante.",
              address: "8 Boulevard du Temple, Paris 11ème",
              capacity: 40,
              price_per_hour: 60,
              rating: 4.7,
              images: "https://images.unsplash.com/photo-1577412647305-991150c7d163",
              category: "Espaces événementiels"
            }
          ]
        },
        "lyon" => {
          base_coords: [45.7579, 4.8357],
          spaces: [
            {
              name: "Espace Confluence",
              description: "Grand espace modulable dans le quartier moderne de Confluence. Idéal pour les événements d'entreprise, formations et séminaires.",
              address: "12 Cours Charlemagne, Lyon 2ème",
              capacity: 60,
              price_per_hour: 75,
              rating: 4.6,
              images: "https://images.unsplash.com/photo-1517502884422-41eaead166d4",
              category: "Espaces événementiels"
            },
            {
              name: "Salle Croix-Rousse",
              description: "Salle cosy sur les pentes de la Croix-Rousse, parfaite pour les réunions de travail. Ambiance chaleureuse et authentique.",
              address: "5 Rue des Pierres Plantées, Lyon 1er",
              capacity: 20,
              price_per_hour: 40,
              rating: 4.5,
              images: "https://images.unsplash.com/photo-1534298261662-f8fdd25317db",
              category: "Salles de réunion"
            }
          ]
        },
        "nancy" => {
          base_coords: [48.6921, 6.1844],
          spaces: [
            {
              name: "Espace Stanislas",
              description: "Belle salle historique près de la place Stanislas. Architecture XVIIIe siècle, plafonds hauts et équipement moderne.",
              address: "15 Rue des Dominicains, Nancy",
              capacity: 30,
              price_per_hour: 50,
              rating: 4.7,
              images: "https://images.unsplash.com/photo-1517502166878-35c93a0072f0",
              category: "Espaces événementiels"
            },
            {
              name: "Studio Art Déco Nancy",
              description: "Studio inspiré du mouvement Art Déco nancéien. Parfait pour les photoshoots, ateliers créatifs et petites réceptions.",
              address: "8 Rue Émile Gallé, Nancy",
              capacity: 8,
              price_per_hour: 35,
              rating: 4.8,
              images: "https://images.unsplash.com/photo-1519167115178-d40f3b7b4897",
              category: "Ateliers créatifs"
            },
            {
              name: "Petit Atelier Place Carnot",
              description: "Charmant petit atelier à deux pas de la Place Carnot. Idéal pour les réunions intimes et les ateliers créatifs en petit comité.",
              address: "3 Rue Saint-Dizier, Nancy",
              capacity: 6,
              price_per_hour: 30,
              rating: 4.9,
              images: "https://images.unsplash.com/photo-1520013333832-607bb507f2ce",
              category: "Ateliers créatifs"
            }
          ]
        },
        "bordeaux" => {
          base_coords: [44.8378, -0.5792],
          spaces: [
            {
              name: "Atelier Chartrons",
              description: "Bel atelier lumineux dans le quartier des Chartrons. Idéal pour les ateliers créatifs et les petits événements.",
              address: "45 Rue Notre Dame, Bordeaux",
              capacity: 25,
              price_per_hour: 40,
              rating: 4.7,
              images: "https://images.unsplash.com/photo-1505409859467-3a796fd5798e",
              category: "Ateliers créatifs"
            },
            {
              name: "Salle Conférence Quinconces",
              description: "Salle de conférence moderne au cœur de Bordeaux. Équipement audiovisuel haut de gamme, parfait pour vos présentations professionnelles.",
              address: "12 Allées de Tourny, Bordeaux",
              capacity: 80,
              price_per_hour: 90,
              rating: 4.9,
              images: "https://images.unsplash.com/photo-1573167507387-6b4b98cb7c13",
              category: "Espaces événementiels"
            },
            {
              name: "Petit Studio Saint-Pierre",
              description: "Charmant studio au cœur du quartier Saint-Pierre. Parfait pour les petites réunions et séances de travail en équipe restreinte.",
              address: "7 Rue Saint-Pierre, Bordeaux",
              capacity: 8,
              price_per_hour: 35,
              rating: 4.8,
              images: "https://images.unsplash.com/photo-1497366811353-6870744d04b2",
              category: "Salles de réunion"
            }
          ]
        },
        "lille" => {
          base_coords: [50.6365, 3.0635],
          spaces: [
            {
              name: "Espace Vieux-Lille",
              description: "Charmant espace dans une maison flamande du Vieux-Lille. Idéal pour les réunions et ateliers dans un cadre authentique.",
              address: "24 Rue de la Monnaie, Lille",
              capacity: 20,
              price_per_hour: 45,
              rating: 4.6,
              images: "https://images.unsplash.com/photo-1532916123995-50bad0972526",
              category: "Salles de réunion"
            },
            {
              name: "Loft Euralille",
              description: "Grand loft moderne proche d'Euralille. Espace ouvert et lumineux, parfait pour les événements corporate.",
              address: "142 Avenue Willy Brandt, Lille",
              capacity: 100,
              price_per_hour: 110,
              rating: 4.8,
              images: "https://images.unsplash.com/photo-1505409859467-3a796fd5798e",
              category: "Espaces événementiels"
            },
            {
              name: "Studio Créatif République",
              description: "Petit studio créatif à proximité de la place de la République. Parfait pour les réunions en petit comité et les séances de brainstorming.",
              address: "5 Rue du Molinel, Lille",
              capacity: 10,
              price_per_hour: 35,
              rating: 4.7,
              images: "https://images.unsplash.com/photo-1522071820081-009f0129c71c",
              category: "Ateliers créatifs"
            }
          ]
        }
      }
      
      # Vérifier si l'emplacement correspond à une ville connue (insensible à la casse)
      location_key = @location.downcase.strip
      cities_data.keys.each do |city_name|
        if location_key.include?(city_name)
          # Créer des objets Space temporaires
          city_data = cities_data[city_name]
          
          city_data[:spaces].each_with_index do |space_data, index|
            # Créer un objet Space temporaire avec les données fournies
            space = Space.new(space_data)
            space.id = -(index + 1)  # Assignation d'IDs temporaires négatifs
            space.latitude = city_data[:base_coords][0] + (index * 0.005)  # Légère variation pour les marqueurs
            space.longitude = city_data[:base_coords][1] + (index * 0.005)
            
            # Filtrer par capacité si nécessaire
            next if @capacity_filter.present? && capacity_range && !capacity_range.include?(space.capacity)
            
            example_spaces << space
          end
          
          break
        end
      end
      
      # Assigner les espaces temporaires à @spaces
      @spaces = example_spaces
      
      # Trier selon le critère spécifié
      case @sort
      when "price_asc"
        @spaces.sort_by! { |s| s.price_per_hour }
      when "price_desc"
        @spaces.sort_by! { |s| -s.price_per_hour }
      when "capacity"
        @spaces.sort_by! { |s| -s.capacity }
      else
        @spaces.sort_by! { |s| -s.rating } # Par défaut, trier par évaluation
      end
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
    
    # Rendu de la vue search
    respond_to do |format|
      format.html
      format.json { render json: { spaces: @spaces, markers: @markers } }
    end
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