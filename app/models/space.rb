class Space < ApplicationRecord
  # Constantes pour les catégories et équipements
  CATEGORIES = [
    ["Salle de réunion", "salle_reunion"],
    ["Espace de coworking", "coworking"],
    ["Espace événementiel", "evenementiel"],
    ["Atelier créatif", "atelier"],
    ["Espace sportif", "sport"],
    ["Autre", "autre"]
  ]
  
  AMENITIES = [
    ["WiFi", "wifi"],
    ["Vidéoprojecteur", "videoprojecteur"],
    ["Tableau blanc", "tableau"],
    ["Cuisine", "cuisine"],
    ["Climatisation", "climatisation"],
    ["Accessible PMR", "accessible_pmr"],
    ["Parking", "parking"]
  ]
  
  # Associations
  belongs_to :user, optional: true
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  # has_many :availabilities, dependent: :destroy
  # has_many :space_amenities, dependent: :destroy
  has_many :amenities, through: :space_amenities
  
  # Ajouter pour les photos
  has_many_attached :images
  has_many_attached :photos # Pour compatibilité avec le code de carte
  
  # Pour les équipements (stockés comme un tableau dans un champ texte)
  serialize :amenities, coder: YAML, unless: -> { defined?(space_amenities) }
  
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :address, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  
  # Alias pour la compatibilité avec les différentes versions du code
  alias_attribute :hourly_price, :price_per_hour
  
  # Geocoding 
  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?
  
  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_capacity, ->(min, max = nil) { 
    if max
      where(capacity: min..max)
    else
      where("capacity >= ?", min)
    end
  }
  scope :by_location, ->(query) { where("address LIKE ? OR city LIKE ?", "%#{query}%", "%#{query}%") if query.present? }
  scope :by_price, ->(min, max = nil) {
    if max
      where(price_per_hour: min..max)
    else
      where("price_per_hour >= ?", min)
    end
  }
  scope :featured, -> { where("rating >= ?", 4.5).order(rating: :desc).limit(3) }
  scope :newest, -> { order(created_at: :desc) }
  
  # Méthodes d'instance
  
  # Retourne l'adresse complète pour le géocodage
  def full_address
    components = [address]
    components << postal_code if respond_to?(:postal_code) && postal_code.present?
    components << city if respond_to?(:city) && city.present?
    components << country if respond_to?(:country) && country.present?
    components.compact.join(', ')
  end
  
  # Déterminer si le géocodage est nécessaire
  def should_geocode?
    address_changed? || 
    (respond_to?(:city_changed?) && city_changed?) || 
    (respond_to?(:postal_code_changed?) && postal_code_changed?) || 
    (respond_to?(:country_changed?) && country_changed?)
  end
  
  # Retourne une version courte de l'adresse pour l'affichage
  def address_short
    if respond_to?(:city) && city.present? && respond_to?(:postal_code) && postal_code.present?
      "#{city}, #{postal_code.first(2)}"
    elsif respond_to?(:city) && city.present?
      city
    else
      # Retourne une version courte de l'adresse (ex: juste la ville et le code postal)
      address.split(',').last(2).join(',').strip rescue address
    end
  end
  
  def featured?
    # Un espace est considéré comme "en vedette" s'il a une note élevée
    average_rating >= 4.5
  end
  
  def new_space?
    # Un espace est considéré comme "nouveau" s'il a été créé récemment
    created_at && created_at >= 30.days.ago
  end
  
  # Calcule la note moyenne à partir des avis
  def average_rating
    return rating if respond_to?(:rating) && !rating.nil?
    return 0 if !respond_to?(:reviews) || reviews.nil? || reviews.empty?
    (reviews.average(:rating) || 0).round(1)
  end
  
  # Récupère les URLs des photos pour l'affichage dans la carte
  def photos_urls
    if respond_to?(:photos) && photos.respond_to?(:attached?) && photos.attached?
      photos.map { |photo| Rails.application.routes.url_helpers.url_for(photo) }
    elsif respond_to?(:images) && images.respond_to?(:attached?) && images.attached?
      images.map { |image| Rails.application.routes.url_helpers.url_for(image) }
    else
      nil
    end
  end
  
  # S'assurer que les attributs nécessaires pour la vue carte existent
  def method_missing(method_name, *arguments, &block)
    # Liste des méthodes que nous voulons simuler si elles n'existent pas
    if [:latitude, :longitude, :hourly_price, :capacity, :average_rating, :address_short].include?(method_name)
      nil
    else
      super
    end
  end
  
  def respond_to_missing?(method_name, include_private = false)
    [:latitude, :longitude, :hourly_price, :capacity, :average_rating, :address_short].include?(method_name) || super
  end
  
  def available_at?(date, start_time, end_time)
    # Vérifie si l'espace est disponible à la date et aux horaires spécifiés
    # Cette méthode dépend de la structure de votre modèle Booking
    bookings.where(date: date).none? do |booking|
      # Convertir les chaînes de temps en objets Time pour comparaison
      booking_start = Time.parse(booking.start_time.strftime("%H:%M"))
      booking_end = Time.parse(booking.end_time.strftime("%H:%M"))
      check_start = Time.parse(start_time)
      check_end = Time.parse(end_time)
      
      # Vérifier si les plages se chevauchent
      (check_start < booking_end) && (check_end > booking_start)
    end
  end
  
  def available_dates(start_date = Date.today, end_date = 1.month.from_now.to_date)
    # Retourne un tableau de dates disponibles dans la plage spécifiée
    (start_date..end_date).select do |date|
      bookings.where(date: date).count < max_bookings_per_day
    end
  end
  
  def max_bookings_per_day
    # Nombre maximum de réservations par jour (à ajuster selon vos besoins)
    # Par défaut, on considère qu'un espace ne peut être réservé qu'une fois par jour
    1
  end
  
  def price_for_duration(hours)
    # Calcule le prix pour une durée spécifiée en heures
    (price_per_hour * hours).round(2)
  end
  
  # Méthodes pour la gestion des équipements
  def has_amenity?(amenity_name)
    return amenities.include?(amenity_name) if amenities.is_a?(Array)
    return amenities.map(&:name).include?(amenity_name) if respond_to?(:space_amenities) && space_amenities.any?
    false
  end
  
  # Méthode pour vérifier une disponibilité spécifique
  def available_on_day?(day_of_week)
    availabilities.where(day_of_week: day_of_week).exists?
  end
  
  # Obtenir toutes les disponibilités pour un jour spécifique
  def availabilities_for_day(day_of_week)
    availabilities.where(day_of_week: day_of_week).order(:start_time)
  end
  
  # Méthode pour configurer les disponibilités à partir des données du formulaire
  def update_availabilities(availabilities_params)
    return unless availabilities_params
    
    # Supprimer les anciennes disponibilités
    self.availabilities.destroy_all
    
    # Créer les nouvelles disponibilités
    availabilities_params.each do |index, availability_data|
      next unless availability_data[:available] == "1"
      
      self.availabilities.create(
        day_of_week: index.to_i,
        start_time: availability_data[:start_time],
        end_time: availability_data[:end_time]
      )
    end
  end
  
  # Méthodes de classe
  
  # Recherche des espaces par ville ou adresse
  def self.search_by_location(query)
    where('lower(city) LIKE :query OR lower(address) LIKE :query', query: "%#{query.downcase}%")
  end
  
  # Récupère les espaces populaires (avec les meilleures notes)
  def self.popular
    joins(:reviews).group('spaces.id').order('AVG(reviews.rating) DESC').limit(6)
  rescue
    order(rating: :desc).limit(6)
  end
  
  # Récupère les espaces récemment ajoutés
  def self.recent
    order(created_at: :desc).limit(6)
  end
  
  def self.search(params)
    spaces = self.all
    
    # Filtrer par emplacement
    spaces = spaces.by_location(params[:location]) if params[:location].present?
    
    # Filtrer par catégorie
    spaces = spaces.by_category(params[:category]) if params[:category].present?
    
    # Filtrer par capacité
    if params[:capacity].present?
      capacity_range = case params[:capacity]
                       when "1-10 personnes" then [1, 10]
                       when "11-30 personnes" then [11, 30]
                       when "31-50 personnes" then [31, 50]
                       when "Plus de 50 personnes" then [51, nil]
                       else nil
                       end
      
      if capacity_range
        spaces = spaces.by_capacity(capacity_range[0], capacity_range[1])
      end
    end
    
    # Filtrer par disponibilité si date et horaires spécifiés
    if params[:date].present? && params[:start_time].present? && params[:end_time].present?
      date = Date.parse(params[:date]) rescue nil
      start_time = params[:start_time]
      end_time = params[:end_time]
      
      if date && start_time && end_time
        spaces = spaces.select { |space| space.available_at?(date, start_time, end_time) }
      end
    end
    
    spaces
  end
  
  # Ajouter des méthodes utilitaires pour les équipements
  def self.amenity_categories
    {
      basic: ["wifi", "tables", "restroom", "heating"],
      av: ["projector", "screen", "sound_system", "microphone"],
      comfort: ["kitchen", "coffee", "refrigerator", "wheelchair"]
    }
  end
  
  def self.amenity_labels
    {
      "wifi" => "WiFi",
      "tables" => "Tables et chaises",
      "restroom" => "Toilettes",
      "heating" => "Chauffage",
      "projector" => "Vidéoprojecteur",
      "screen" => "Écran de projection",
      "sound_system" => "Système sonore",
      "microphone" => "Microphone",
      "kitchen" => "Cuisine/Coin cuisine",
      "coffee" => "Machine à café",
      "refrigerator" => "Réfrigérateur",
      "wheelchair" => "Accessible PMR"
    }
  end
  
  def self.cancellation_policies
    {
      "flexible" => "Flexible (annulation gratuite jusqu'à 24h avant)",
      "moderate" => "Modérée (annulation gratuite jusqu'à 3 jours avant)",
      "strict" => "Stricte (annulation gratuite jusqu'à 7 jours avant)"
    }
  end
end