puts "Nettoyage de la base de données..."
Space.destroy_all
Need.destroy_all if defined?(Need)
Category.destroy_all if defined?(Category)

puts "Création des catégories..."
categories = [
  {name: "Salles de réunion", description: "Parfaites pour vos réunions et ateliers"},
  {name: "Espaces événementiels", description: "Idéaux pour vos conférences et événements"},
  {name: "Ateliers créatifs", description: "Des espaces conçus pour la création et l'artisanat"},
  {name: "Espaces sportifs", description: "Pour les activités sportives et le bien-être"}
]
categories.each { |cat| Category.create!(cat) }

puts "Création de l'utilisateur admin..."
user = User.find_or_create_by!(email: 'admin@lelocal.fr') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.first_name = 'Admin'
  u.last_name = 'LeLocal'
  u.association_name = 'Les Lilas de la rue Mortier'
end

# Création d'autres utilisateurs pour diversifier les associations
puts "Création d'utilisateurs pour les associations..."
users = [
  {
    email: 'culturelle@asso.fr',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Marie',
    last_name: 'Dubois',
    association_name: 'Association Culturelle de Lyon'
  },
  {
    email: 'sport@asso.fr',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Pierre',
    last_name: 'Martin',
    association_name: 'Sportifs Solidaires'
  },
  {
    email: 'enfants@asso.fr',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Sophie',
    last_name: 'Laurent',
    association_name: 'Les Petits Créateurs'
  },
  {
    email: 'theatre@asso.fr',
    password: 'password123',
    password_confirmation: 'password123',
    first_name: 'Thomas',
    last_name: 'Bernard',
    association_name: 'Compagnie des Trois Actes'
  }
]

created_users = []
users.each do |user_data|
  created_users << User.find_or_create_by!(email: user_data[:email]) do |u|
    u.password = user_data[:password]
    u.password_confirmation = user_data[:password_confirmation]
    u.first_name = user_data[:first_name]
    u.last_name = user_data[:last_name]
    u.association_name = user_data[:association_name]
  end
end
created_users << user

puts "Création des espaces..."
[
  {
    name: "Espace Créatif Montmartre",
    description: "Espace lumineux au cœur de Montmartre",
    address: "18 Rue des Abbesses, Paris",
    capacity: 25,
    price_per_hour: 45,
    latitude: 48.8845,
    longitude: 2.3322,
    category: "Ateliers créatifs"
  },
  {
    name: "Salle Confluence",
    description: "Grande salle à Lyon pour séminaires",
    address: "12 Cours Charlemagne, Lyon",
    capacity: 60,
    price_per_hour: 75,
    latitude: 45.7464,
    longitude: 4.8197,
    category: "Espaces événementiels"
  }
].each do |space_data|
  category = Category.find_by(name: space_data.delete(:category))
  Space.create!(space_data.merge(category: category))
end

puts "Création des besoins..."
needs = [
  # Paris et région parisienne
  {
    title: "Recherche salle pour répétition théâtrale",
    description: "La Compagnie des Trois Actes cherche une salle pour répéter notre nouvelle pièce 'Les Quatre Saisons'. Nous avons besoin d'un espace assez grand avec une bonne acoustique.",
    category: "atelier",
    address: "25 rue des Martyrs",
    city: "Paris",
    postal_code: "75009",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "18:00",
    end_time: "21:00",
    budget: 50,
    recurrence: "weekly",
    latitude: 48.8763,
    longitude: 2.3397,
    equipment_needs: ["système son", "chaises", "espace dégagé"]
  },
  {
    title: "Local pour cours de danse contemporaine",
    description: "Association de danse contemporaine recherche studio avec parquet ou lino pour des cours hebdomadaires. Miroirs appréciés.",
    category: "atelier",
    address: "14 rue de la Roquette",
    city: "Paris",
    postal_code: "75011",
    country: "France",
    capacity: 20,
    date_needed: 10.days.from_now,
    start_time: "19:30",
    end_time: "21:30",
    budget: 40,
    recurrence: "weekly",
    latitude: 48.8534,
    longitude: 2.3709,
    equipment_needs: ["miroirs", "système son"]
  },
  {
    title: "Recherche salle pour réunion mensuelle",
    description: "Notre association de protection de l'environnement recherche une salle pour nos réunions mensuelles du conseil d'administration et occasionnellement pour des conférences.",
    category: "réunion",
    address: "5 avenue Daumesnil",
    city: "Paris",
    postal_code: "75012",
    country: "France",
    capacity: 25,
    date_needed: 3.weeks.from_now,
    start_time: "14:00",
    end_time: "17:00",
    budget: 60,
    recurrence: "monthly",
    latitude: 48.8423,
    longitude: 2.3825,
    equipment_needs: ["vidéoprojecteur", "tables", "chaises", "wifi"]
  },
  {
    title: "Atelier d'arts plastiques pour enfants",
    description: "Les Petits Créateurs cherchent une salle lumineuse pour animer des ateliers d'arts plastiques destinés aux enfants de 6 à 12 ans. Point d'eau nécessaire.",
    category: "atelier",
    address: "18 rue des Lilas",
    city: "Montreuil",
    postal_code: "93100",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "14:00",
    end_time: "16:30",
    budget: 45,
    recurrence: "weekly",
    latitude: 48.8636,
    longitude: 2.4349,
    equipment_needs: ["tables", "point d'eau", "éclairage naturel"]
  },
  {
    title: "Salle pour conférence écologique",
    description: "Organisation d'une conférence sur la transition écologique avec projection de documentaire suivi d'un débat. Besoin d'un lieu facile d'accès.",
    category: "événement",
    address: "10 rue Victor Hugo",
    city: "Saint-Denis",
    postal_code: "93200",
    country: "France",
    capacity: 80,
    date_needed: 1.month.from_now,
    start_time: "18:30",
    end_time: "22:00",
    budget: 200,
    recurrence: "once",
    latitude: 48.9362,
    longitude: 2.3540,
    equipment_needs: ["vidéoprojecteur", "sonorisation", "micro", "chaises"]
  },
  
  # Lyon et région
  {
    title: "Local pour cours de yoga",
    description: "Association de yoga cherche salle calme et lumineuse pour cours hebdomadaires de Hatha Yoga. Accessible aux personnes à mobilité réduite.",
    category: "sport",
    address: "25 rue de la République",
    city: "Lyon",
    postal_code: "69001",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "18:00",
    end_time: "20:00",
    budget: 35,
    recurrence: "weekly",
    latitude: 45.767,
    longitude: 4.836,
    equipment_needs: ["chauffage", "espace dégagé"]
  },
  {
    title: "Atelier cuisine participative",
    description: "Nous organisons des ateliers cuisine participative autour des recettes du monde. Recherche cuisine équipée ou semi-professionnelle.",
    category: "atelier",
    address: "5 place Bellecour",
    city: "Lyon",
    postal_code: "69002",
    country: "France",
    capacity: 12,
    date_needed: 3.weeks.from_now,
    start_time: "10:00",
    end_time: "14:00",
    budget: 100,
    recurrence: "monthly",
    latitude: 45.7578,
    longitude: 4.8327,
    equipment_needs: ["cuisine équipée", "réfrigérateur", "plan de travail"]
  },
  {
    title: "Répétition de chorale",
    description: "Chorale amateur de 20 personnes cherche espace pour répétitions hebdomadaires. Une bonne acoustique est primordiale.",
    category: "atelier",
    address: "15 rue de la Part-Dieu",
    city: "Lyon",
    postal_code: "69003",
    country: "France",
    capacity: 25,
    date_needed: 10.days.from_now,
    start_time: "20:00",
    end_time: "22:00",
    budget: 40,
    recurrence: "weekly",
    latitude: 45.7605,
    longitude: 4.8564,
    equipment_needs: ["piano", "chaises", "pupitre"]
  },
  
  # Marseille
  {
    title: "Espace pour exposition photo",
    description: "Collectif de photographes cherche lieu pour exposition temporaire de 1 semaine. Éclairage adapté et murs pour accrocher les œuvres nécessaires.",
    category: "événement",
    address: "25 rue Paradis",
    city: "Marseille",
    postal_code: "13001",
    country: "France",
    capacity: 50,
    date_needed: 2.months.from_now,
    start_time: "10:00",
    end_time: "19:00",
    budget: 350,
    recurrence: "once",
    latitude: 43.2967,
    longitude: 5.3764,
    equipment_needs: ["éclairage", "cimaises", "tables d'accueil"]
  },
  {
    title: "Salle pour conférence médicale",
    description: "Association de soutien aux malades organise une conférence avec 3 médecins spécialistes. Besoin d'une salle de conférence bien équipée.",
    category: "événement",
    address: "9 boulevard Michelet",
    city: "Marseille",
    postal_code: "13008",
    country: "France",
    capacity: 100,
    date_needed: 6.weeks.from_now,
    start_time: "14:00",
    end_time: "18:00",
    budget: 250,
    recurrence: "once",
    latitude: 43.2692,
    longitude: 5.3855,
    equipment_needs: ["sonorisation", "vidéoprojecteur", "micros", "chaises"]
  },
  
  # Bordeaux
  {
    title: "Espace pour ateliers d'écriture",
    description: "Nous organisons des ateliers d'écriture créative et cherchons un lieu calme et inspirant, idéalement avec un petit jardin ou vue agréable.",
    category: "atelier",
    address: "12 rue Sainte-Catherine",
    city: "Bordeaux",
    postal_code: "33000",
    country: "France",
    capacity: 15,
    date_needed: 3.weeks.from_now,
    start_time: "16:00",
    end_time: "19:00",
    budget: 60,
    recurrence: "biweekly",
    latitude: 44.8412,
    longitude: -0.5731,
    equipment_needs: ["tables", "chaises", "tableau"]
  },
  {
    title: "Local pour ateliers musicaux",
    description: "Association proposant des cours de musique pour débutants cherche salle pour ateliers découverte d'instruments de musique.",
    category: "atelier",
    address: "25 quai des Chartrons",
    city: "Bordeaux",
    postal_code: "33000",
    country: "France",
    capacity: 20,
    date_needed: 1.month.from_now,
    start_time: "14:00",
    end_time: "17:00",
    budget: 80,
    recurrence: "weekly",
    latitude: 44.8520,
    longitude: -0.5648,
    equipment_needs: ["isolation phonique", "prises électriques", "chaises"]
  },
  
  # Lille
  {
    title: "Salle pour assemblée générale",
    description: "Association de quartier recherche salle pour notre assemblée générale annuelle. Environ 40 participants prévus.",
    category: "réunion",
    address: "5 place Rihour",
    city: "Lille",
    postal_code: "59000",
    country: "France",
    capacity: 50,
    date_needed: 2.months.from_now,
    start_time: "18:30",
    end_time: "21:00",
    budget: 120,
    recurrence: "once",
    latitude: 50.6374,
    longitude: 3.0619,
    equipment_needs: ["vidéoprojecteur", "micro", "tables", "chaises"]
  },
  {
    title: "Espace sportif pour cours de boxe éducative",
    description: "Notre association d'insertion par le sport cherche salle avec espace dégagé pour cours de boxe éducative pour adolescents.",
    category: "sport",
    address: "10 rue Nationale",
    city: "Lille",
    postal_code: "59000",
    country: "France",
    capacity: 15,
    date_needed: 3.weeks.from_now,
    start_time: "17:00",
    end_time: "19:00",
    budget: 50,
    recurrence: "weekly",
    latitude: 50.6305,
    longitude: 3.0710,
    equipment_needs: ["espace dégagé", "tapis de sol", "vestiaires"]
  },
  
  # Nantes
  {
    title: "Lieu pour festival associatif",
    description: "Organisation d'un petit festival associatif sur le thème du développement durable. Besoin d'espace intérieur et extérieur si possible.",
    category: "événement",
    address: "2 rue de la Paix",
    city: "Nantes",
    postal_code: "44000",
    country: "France",
    capacity: 150,
    date_needed: 3.months.from_now,
    start_time: "10:00",
    end_time: "22:00",
    budget: 500,
    recurrence: "once",
    latitude: 47.2139,
    longitude: -1.5551,
    equipment_needs: ["sonorisation", "éclairage", "tables", "chaises", "accès eau et électricité"]
  },
  {
    title: "Local pour ateliers de sensibilisation",
    description: "Association de prévention santé cherche salle pour animer des ateliers de sensibilisation auprès des jeunes.",
    category: "atelier",
    address: "15 boulevard Guist'hau",
    city: "Nantes",
    postal_code: "44000",
    country: "France",
    capacity: 30,
    date_needed: 1.month.from_now,
    start_time: "13:30",
    end_time: "16:30",
    budget: 70,
    recurrence: "monthly",
    latitude: 47.2227,
    longitude: -1.5606,
    equipment_needs: ["connexion internet", "tables en îlots"]
  },
  
  # Nancy (10 nouveaux besoins)
  {
    title: "Salle pour cours de théâtre amateur",
    description: "Troupe de théâtre amateur cherche salle pour répétitions hebdomadaires. Nous sommes 12 comédiens et travaillons sur une adaptation de Molière.",
    category: "atelier",
    address: "10 rue Saint-Dizier",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "19:00",
    end_time: "22:00",
    budget: 60,
    recurrence: "weekly",
    latitude: 48.6921,
    longitude: 6.1844,
    equipment_needs: ["espace dégagé", "chaises", "quelques accessoires"]
  },
  {
    title: "Local pour atelier d'art-thérapie",
    description: "Association de soutien psychologique recherche espace calme et lumineux pour séances d'art-thérapie en petits groupes.",
    category: "atelier",
    address: "25 rue des Dominicains",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 10,
    date_needed: 3.weeks.from_now,
    start_time: "14:00",
    end_time: "16:30",
    budget: 45,
    recurrence: "weekly",
    latitude: 48.6897,
    longitude: 6.1803,
    equipment_needs: ["tables", "point d'eau", "éclairage de qualité"]
  },
  {
    title: "Espace pour conférence sur l'histoire locale",
    description: "Association du patrimoine lorrain organise une conférence sur l'histoire industrielle de Nancy avec projection de documents d'archives.",
    category: "événement",
    address: "8 place Stanislas",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 60,
    date_needed: 1.month.from_now,
    start_time: "18:00",
    end_time: "20:30",
    budget: 150,
    recurrence: "once",
    latitude: 48.6936,
    longitude: 6.1832,
    equipment_needs: ["vidéoprojecteur", "sonorisation", "chaises", "podium"]
  },
  {
    title: "Salle pour chorale gospel",
    description: "Chorale gospel de 25 personnes cherche salle pour répétitions hebdomadaires. Bonne acoustique indispensable.",
    category: "atelier",
    address: "15 rue Gustave Simon",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 30,
    date_needed: 2.weeks.from_now,
    start_time: "20:00",
    end_time: "22:00",
    budget: 50,
    recurrence: "weekly",
    latitude: 48.6917,
    longitude: 6.1870,
    equipment_needs: ["piano ou clavier", "chaises", "bonne acoustique"]
  },
  {
    title: "Local pour ateliers de jeux de société",
    description: "Club de jeux de société cherche espace convivial pour organiser des après-midis et soirées jeux ouverts à tout public.",
    category: "loisirs",
    address: "30 rue Raymond Poincaré",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 25,
    date_needed: 10.days.from_now,
    start_time: "14:00",
    end_time: "22:00",
    budget: 80,
    recurrence: "biweekly",
    latitude: 48.6858,
    longitude: 6.1738,
    equipment_needs: ["tables larges", "chaises confortables", "éclairage adapté"]
  },
  {
    title: "Espace pour cours de cuisine diététique",
    description: "Association de promotion de la santé par l'alimentation cherche cuisine équipée pour ateliers de cuisine diététique et végétarienne.",
    category: "atelier",
    address: "12 rue Sainte-Catherine",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 12,
    date_needed: 3.weeks.from_now,
    start_time: "17:30",
    end_time: "20:30",
    budget: 100,
    recurrence: "weekly",
    latitude: 48.6886,
    longitude: 6.1791,
    equipment_needs: ["cuisine équipée", "plan de travail", "réfrigérateur"]
  },
  {
    title: "Salle pour brocante associative",
    description: "Organisation d'une brocante associative au profit d'actions humanitaires. Besoin d'un grand espace couvert pour une journée.",
    category: "événement",
    address: "5 boulevard d'Austrasie",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 150,
    date_needed: 2.months.from_now,
    start_time: "08:00",
    end_time: "18:00",
    budget: 300,
    recurrence: "once",
    latitude: 48.6945,
    longitude: 6.2024,
    equipment_needs: ["tables", "chaises", "accès camion", "toilettes"]
  },
  {
    title: "Salle pour assemblée générale associative",
    description: "Association d'aide aux personnes âgées recherche salle accessible PMR pour notre assemblée générale annuelle avec environ 40 participants.",
    category: "réunion",
    address: "20 rue de la Ravinelle",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 50,
    date_needed: 6.weeks.from_now,
    start_time: "16:00",
    end_time: "19:00",
    budget: 120,
    recurrence: "once",
    latitude: 48.6882,
    longitude: 6.1753,
    equipment_needs: ["vidéoprojecteur", "micros", "accessibilité PMR", "tables"]
  },
  {
    title: "Local pour ateliers jeunesse",
    description: "Association d'éducation populaire cherche espace pour animer des ateliers créatifs et ludiques pour enfants de 7 à 12 ans après l'école.",
    category: "atelier",
    address: "8 rue Cyfflé",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "16:30",
    end_time: "18:30",
    budget: 40,
    recurrence: "weekly",
    latitude: 48.6909,
    longitude: 6.1882,
    equipment_needs: ["tables adaptées enfants", "point d'eau", "rangements"]
  },
  {
    title: "Espace pour projection-débat",
    description: "Ciné-club associatif organise des projections suivies de débats sur des films documentaires. Besoin d'un espace adapté à la projection.",
    category: "événement",
    address: "3 rue Victor Hugo",
    city: "Nancy",
    postal_code: "54000",
    country: "France",
    capacity: 40,
    date_needed: 1.month.from_now,
    start_time: "19:00",
    end_time: "22:30",
    budget: 90,
    recurrence: "monthly",
    latitude: 48.6876,
    longitude: 6.1829,
    equipment_needs: ["système de projection", "sonorisation", "possibilité d'obscurcir la salle", "chaises"]
  },
  
  # Rennes
  {
    title: "Salle pour concert associatif",
    description: "Organisation d'un concert caritatif avec 3 groupes locaux. Tous les bénéfices seront reversés à des associations d'aide à l'enfance.",
    category: "événement",
    address: "15 rue Saint-Michel",
    city: "Rennes",
    postal_code: "35000",
    country: "France",
    capacity: 120,
    date_needed: 2.months.from_now,
    start_time: "19:00",
    end_time: "23:30",
    budget: 350,
    recurrence: "once",
    latitude: 48.1138,
    longitude: -1.6810,
    equipment_needs: ["scène", "sonorisation", "éclairage", "loges"]
  }
]

created = 0
needs.each_with_index do |need_data, index|
  need = Need.new(need_data)
  need.user = created_users[index % created_users.length]  # Répartit les besoins entre les utilisateurs
  if need.save
    puts "✅ Besoin créé : #{need.title}"
    created += 1
  else
    puts "❌ Erreur : #{need.errors.full_messages.join(', ')}"
  end
end

puts "Seeding terminé avec succès. #{created} besoin(s) créé(s)."
