class Space < ApplicationRecord
  # Constantes
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

  # Associations principales
  belongs_to :user, optional: true
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  # has_many :availabilities, dependent: :destroy

  # ⚠️ PAS d'association amenities en through: on utilise la colonne
  # has_many :space_amenities, dependent: :destroy
  # has_many :amenities, through: :space_amenities

  # Fichiers
  has_many_attached :images
  has_many_attached :photos

  # Équipements stockés dans la colonne `amenities`
  # (TEXT/JSON). YAML marche si colonne TEXT.
  serialize :amenities, coder: YAML

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :address, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true

  alias_attribute :hourly_price, :price_per_hour

  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: :should_geocode?

  # Scopes
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_capacity, ->(min, max = nil) { max ? where(capacity: min..max) : where("capacity >= ?", min) }
  scope :by_location, ->(query) { where("address LIKE ? OR city LIKE ?", "%#{query}%", "%#{query}%") if query.present? }
  scope :by_price, ->(min, max = nil) { max ? where(price_per_hour: min..max) : where("price_per_hour >= ?", min) }
  scope :featured, -> { where("rating >= ?", 4.5).order(rating: :desc).limit(3) }
  scope :newest, -> { order(created_at: :desc) }

  # --- Méthodes d’instance ---

  def full_address
    components = [address]
    components << postal_code if respond_to?(:postal_code) && postal_code.present?
    components << city        if respond_to?(:city) && city.present?
    components << country     if respond_to?(:country) && country.present?
    components.compact.join(', ')
  end

  def should_geocode?
    address_changed? ||
      (respond_to?(:city_changed?) && city_changed?) ||
      (respond_to?(:postal_code_changed?) && postal_code_changed?) ||
      (respond_to?(:country_changed?) && country_changed?)
  end

  def address_short
    if respond_to?(:city) && city.present? && respond_to?(:postal_code) && postal_code.present?
      "#{city}, #{postal_code.first(2)}"
    elsif respond_to?(:city) && city.present?
      city
    else
      address.split(',').last(2).join(',').strip rescue address
    end
  end

  def featured?
    average_rating >= 4.5
  end

  def new_space?
    created_at && created_at >= 30.days.ago
  end

  def average_rating
    return rating if respond_to?(:rating) && !rating.nil?
    return 0 unless respond_to?(:reviews) && reviews.present?
    (reviews.average(:rating) || 0).round(1)
  end

  def photos_urls
    if photos.respond_to?(:attached?) && photos.attached?
      photos.map { |p| Rails.application.routes.url_helpers.url_for(p) }
    elsif images.respond_to?(:attached?) && images.attached?
      images.map { |i| Rails.application.routes.url_helpers.url_for(i) }
    end
  end

  # Équipements
  def has_amenity?(amenity_name)
    amenities.is_a?(Array) ? amenities.include?(amenity_name) : false
  end

  # (Les méthodes sur availabilities ne seront actives que si tu remets l’association)
  def available_on_day?(day_of_week)
    respond_to?(:availabilities) && availabilities.where(day_of_week: day_of_week).exists?
  end

  def availabilities_for_day(day_of_week)
    respond_to?(:availabilities) ? availabilities.where(day_of_week: day_of_week).order(:start_time) : []
  end

  # Prix utilitaire
  def price_for_duration(hours)
    (price_per_hour * hours).round(2)
  end

  # Compat : éviter de casser si certaines colonnes n’existent pas
  def method_missing(method_name, *args, &block)
    if [:latitude, :longitude, :hourly_price, :capacity, :average_rating, :address_short].include?(method_name)
      nil
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    [:latitude, :longitude, :hourly_price, :capacity, :average_rating, :address_short].include?(method_name) || super
  end

  # --- Méthodes de classe ---

  def self.search_by_location(query)
    where('lower(city) LIKE :q OR lower(address) LIKE :q', q: "%#{query.downcase}%")
  end

  def self.popular
    joins(:reviews).group('spaces.id').order('AVG(reviews.rating) DESC').limit(6)
  rescue
    order(rating: :desc).limit(6)
  end

  def self.recent
    order(created_at: :desc).limit(6)
  end

  def self.search(params)
    spaces = all
    spaces = spaces.by_location(params[:location]) if params[:location].present?
    spaces = spaces.by_category(params[:category]) if params[:category].present?

    if params[:capacity].present?
      case params[:capacity]
      when "1-10 personnes"     then spaces = spaces.by_capacity(1, 10)
      when "11-30 personnes"    then spaces = spaces.by_capacity(11, 30)
      when "31-50 personnes"    then spaces = spaces.by_capacity(31, 50)
      when "Plus de 50 personnes" then spaces = spaces.by_capacity(51, nil)
      end
    end

    if params[:date].present? && params[:start_time].present? && params[:end_time].present?
      date = Date.parse(params[:date]) rescue nil
      if date
        spaces = spaces.select { |space| space.available_at?(date, params[:start_time], params[:end_time]) }
      end
    end

    spaces
  end

  def self.amenity_categories
    { basic: %w[wifi tables restroom heating],
      av:    %w[projector screen sound_system microphone],
      comfort: %w[kitchen coffee refrigerator wheelchair] }
  end

  def self.amenity_labels
    {
      "wifi" => "WiFi", "tables" => "Tables et chaises", "restroom" => "Toilettes", "heating" => "Chauffage",
      "projector" => "Vidéoprojecteur", "screen" => "Écran de projection", "sound_system" => "Système sonore",
      "microphone" => "Microphone", "kitchen" => "Cuisine/Coin cuisine", "coffee" => "Machine à café",
      "refrigerator" => "Réfrigérateur", "wheelchair" => "Accessible PMR"
    }
  end

  def self.cancellation_policies
    {
      "flexible" => "Flexible (annulation gratuite jusqu'à 24h avant)",
      "moderate" => "Modérée (annulation gratuite jusqu'à 3 jours avant)",
      "strict"   => "Stricte (annulation gratuite jusqu'à 7 jours avant)"
    }
  end
end
