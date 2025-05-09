# db/seeds.rb

puts "Nettoyage de la base de données..."
Space.destroy_all
Category.destroy_all if defined?(Category)

puts "Création des catégories..."
categories = [
  {name: "Salles de réunion", description: "Parfaites pour vos réunions et ateliers", image: "https://images.unsplash.com/photo-1577896851231-70ef18881754"},
  {name: "Espaces événementiels", description: "Idéaux pour vos conférences et événements", image: "https://images.unsplash.com/photo-1517245386807-bb43f82c33c4"},
  {name: "Ateliers créatifs", description: "Des espaces conçus pour la création et l'artisanat", image: "https://images.unsplash.com/photo-1574974671999-24b7dfbb0d53"},
  {name: "Espaces sportifs", description: "Pour les activités sportives et le bien-être", image: "https://images.unsplash.com/photo-1526948531399-320e7e40f0ca"}
]

# Si vous avez un modèle Category distinct
if defined?(Category)
  categories.each do |category_attrs|
    Category.create!(category_attrs)
  end
  category_names = Category.all.pluck(:name)
else
  category_names = categories.map { |c| c[:name] }
end

puts "Création des espaces à Paris..."
paris_spaces = [
  {
    name: "Espace Créatif Montmartre",
    description: "Espace lumineux au cœur de Montmartre, idéal pour les réunions créatives et ateliers artistiques. Grande verrière, équipement audio-visuel complet et coin détente inclus.",
    address: "18 Rue des Abbesses, Paris 18ème",
    capacity: 25,
    price_per_hour: 45,
    rating: 4.8,
    images: "https://images.unsplash.com/photo-1497366754035-f200968a6e72",
    latitude: 48.8845,
    longitude: 2.3322,
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
    latitude: 48.8673,
    longitude: 2.3679,
    category: "Espaces événementiels"
  },
  {
    name: "Atelier Artistique Bastille",
    description: "Petit atelier chaleureux proche de la Bastille pour vos activités artistiques. Matériel de peinture disponible, éclairage naturel et ambiance inspirante.",
    address: "12 Rue de la Roquette, Paris 12ème",
    capacity: 15,
    price_per_hour: 35,
    rating: 4.9,
    images: "https://images.unsplash.com/photo-1519167758481-83f550bb49b3",
    latitude: 48.8531,
    longitude: 2.3704,
    category: "Ateliers créatifs"
  }
]

puts "Création des espaces à Lyon..."
lyon_spaces = [
  {
    name: "Espace Confluence",
    description: "Grand espace modulable dans le quartier moderne de Confluence. Idéal pour les événements d'entreprise, formations et séminaires.",
    address: "12 Cours Charlemagne, Lyon 2ème",
    capacity: 60,
    price_per_hour: 75,
    rating: 4.6,
    images: "https://images.unsplash.com/photo-1517502884422-41eaead166d4",
    latitude: 45.7464,
    longitude: 4.8197,
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
    latitude: 45.7745,
    longitude: 4.8308,
    category: "Salles de réunion"
  }
]

puts "Création des espaces à Nancy..."
nancy_spaces = [
  {
    name: "Espace Stanislas",
    description: "Belle salle historique près de la place Stanislas. Architecture XVIIIe siècle, plafonds hauts et équipement moderne.",
    address: "15 Rue des Dominicains, Nancy",
    capacity: 30,
    price_per_hour: 50,
    rating: 4.7,
    images: "https://images.unsplash.com/photo-1517502166878-35c93a0072f0",
    latitude: 48.6921,
    longitude: 6.1844,
    category: "Espaces événementiels"
  },
  {
    name: "Studio Art Déco Nancy",
    description: "Studio inspiré du mouvement Art Déco nancéien. Parfait pour les photoshoots, ateliers créatifs et petites réceptions.",
    address: "8 Rue Émile Gallé, Nancy",
    capacity: 15,
    price_per_hour: 35,
    rating: 4.8,
    images: "https://images.unsplash.com/photo-1519167115178-d40f3b7b4897",
    latitude: 48.6889,
    longitude: 6.1765,
    category: "Ateliers créatifs"
  },
  {
    name: "Centre Sportif Pépinière",
    description: "Espace sportif moderne proche du parc de la Pépinière. Salle multisport, vestiaires et douches inclus.",
    address: "25 Boulevard Albert 1er, Nancy",
    capacity: 50,
    price_per_hour: 65,
    rating: 4.6,
    images: "https://images.unsplash.com/photo-1571902943202-507ec2618e8f",
    latitude: 48.6952,
    longitude: 6.1932,
    category: "Espaces sportifs"
  }
]

puts "Création des espaces à Bordeaux..."
bordeaux_spaces = [
  {
    name: "Atelier Chartrons",
    description: "Bel atelier lumineux dans le quartier des Chartrons. Idéal pour les ateliers créatifs et les petits événements.",
    address: "45 Rue Notre Dame, Bordeaux",
    capacity: 25,
    price_per_hour: 40,
    rating: 4.7,
    images: "https://images.unsplash.com/photo-1505409859467-3a796fd5798e",
    latitude: 44.8536,
    longitude: -0.5723,
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
    latitude: 44.8434,
    longitude: -0.5748,
    category: "Espaces événementiels"
  }
]

puts "Création des espaces à Lille..."
lille_spaces = [
  {
    name: "Espace Vieux-Lille",
    description: "Charmant espace dans une maison flamande du Vieux-Lille. Idéal pour les réunions et ateliers dans un cadre authentique.",
    address: "24 Rue de la Monnaie, Lille",
    capacity: 20,
    price_per_hour: 45,
    rating: 4.6,
    images: "https://images.unsplash.com/photo-1532916123995-50bad0972526",
    latitude: 50.6388,
    longitude: 3.0629,
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
    latitude: 50.6371,
    longitude: 3.0714,
    category: "Espaces événementiels"
  }
]

# Fusionner tous les espaces
# all_spaces = paris_spaces + lyon_spaces + nancy_spaces + bordeaux_spaces + lille_spaces

# Créer les espaces dans la base de données
# all_spaces.each do |space_attrs|
  # S'assurer que la catégorie existe et la récupérer
  # category_name = space_attrs[:category]
  # space_attrs.delete(:category) # Retirer la catégorie des attributs si c'est une string
  
  # Si vous avez un modèle Category distinct
  # if defined?(Category)
  #  category = Category.find_by(name: category_name)
   # space = Space.new(space_attrs)
   # space.category = category
  # else
    # Sinon, utiliser directement le nom de la catégorie
  #   space = Space.new(space_attrs.merge(category: category_name))
  # end
  
 # space.save!
 # puts "Créé : #{space.name} à #{space.address}"
# end

puts "Seed terminé : #{Space.count} espaces créés"