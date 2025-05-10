class Need < ApplicationRecord
  # Constantes pour les catégories de besoins
  CATEGORIES = [
    ["Réunion", "reunion"],
    ["Atelier", "atelier"],
    ["Événement", "evenement"],
    ["Formation", "formation"],
    ["Activité sportive", "sport"],
    ["Autre", "autre"]
  ]
  
  EQUIPMENT_NEEDS = [
    ["WiFi", "wifi"],
    ["Vidéoprojecteur", "videoprojecteur"],
    ["Tableau blanc", "tableau"],
    ["Cuisine", "cuisine"],
    ["Système son", "son"],
    ["Tables et chaises", "mobilier"],
    ["Parking", "parking"]
  ]
  
  # Associations
  belongs_to :user
  has_many_attached :photos
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :category, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :capacity, numericality: { greater_than: 0 }, allow_nil: true
  validates :date_needed, presence: true
  
  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: ->(obj) { obj.address_changed? || obj.city_changed? || 
                                           (obj.postal_code_changed? if obj.respond_to?(:postal_code_changed?)) || 
                                           (obj.country_changed? if obj.respond_to?(:country_changed?)) }
  
  # Pour stocker la liste des équipements nécessaires
  serialize :equipment_needs, Array
  
  # Méthodes d'instance
  
  # Retourne l'adresse complète pour le géocodage
  def full_address
    components = [address]
    components << postal_code if postal_code.present?
    components << city
    components << country if country.present?
    components.compact.join(', ')
  end
  
  # Retourne une version courte de l'adresse pour l'affichage
  def address_short
    if postal_code.present?
      "#{city}, #{postal_code.first(2)}"
    else
      city
    end
  end
  
  # Vérifie si le besoin est urgent (moins de 7 jours)
  def urgent?
    date_needed.present? && date_needed < 7.days.from_now
  end
  
  # Vérifie si le besoin est nouveau (créé au cours des 3 derniers jours)
  def new_need?
    created_at >= 3.days.ago
  end
  
  # Scopes
  scope :upcoming, -> { where("date_needed >= ?", Date.today).order(date_needed: :asc) }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_city, ->(city) { where("city ILIKE ?", "%#{city}%") if city.present? }
  scope :by_capacity, ->(min, max = nil) { 
    if max.nil?
      where("capacity >= ?", min)
    else
      where(capacity: min..max)
    end
  }
  scope :with_equipment, ->(equipment) { where("equipment_needs @> ?", equipment) if equipment.present? }
  
  # Méthodes de classe
  def self.search(params)
    needs = self.all
    
    needs = needs.by_city(params[:location]) if params[:location].present?
    needs = needs.by_category(params[:category]) if params[:category].present?
    
    if params[:date].present?
      date = Date.parse(params[:date]) rescue nil
      needs = needs.where(date_needed: date) if date
    end
    
    if params[:capacity].present?
      case params[:capacity]
      when "1-10"
        needs = needs.by_capacity(1, 10)
      when "11-30"
        needs = needs.by_capacity(11, 30)
      when "31-50"
        needs = needs.by_capacity(31, 50)
      when "50+"
        needs = needs.by_capacity(51)
      end
    end
    
    if params[:equipment].present?
      equipment = Array(params[:equipment])
      needs = needs.with_equipment(equipment)
    end
    
    # Si un budget est spécifié, filtrer par budget
    if params[:max_budget].present?
      needs = needs.where("budget <= ?", params[:max_budget].to_f)
    end
    
    needs
  end
end
