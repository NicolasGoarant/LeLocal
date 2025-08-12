# db/seeds.rb
puts "== Nettoyage =="
# On supprime d'abord ce qui dépend des catégories
Need.destroy_all   if defined?(Need)
Space.destroy_all
Category.destroy_all if defined?(Category)

puts "== Catégories =="
category_specs = [
  { name: "Salles de réunion",   description: "Parfaites pour vos réunions et ateliers" },
  { name: "Espaces événementiels", description: "Idéaux pour vos conférences et événements" },
  { name: "Ateliers créatifs",   description: "Des espaces conçus pour la création et l'artisanat" },
  { name: "Espaces sportifs",    description: "Pour les activités sportives et le bien-être" }
]
categories = category_specs.map { |c| Category.create!(c) }
cats_by_name = Category.all.index_by(&:name)

puts "== Utilisateurs =="
admin = User.find_or_create_by!(email: 'admin@lelocal.fr') do |u|
  u.password = 'password123'
  u.password_confirmation = 'password123'
  u.first_name = 'Admin'
  u.last_name  = 'LeLocal'
  u.association_name = 'Les Lilas de la rue Mortier'
end

users_data = [
  { email: 'culturelle@asso.fr', password: 'password123', first_name: 'Marie',  last_name: 'Dubois',  association_name: 'Association Culturelle de Lyon' },
  { email: 'sport@asso.fr',      password: 'password123', first_name: 'Pierre', last_name: 'Martin',  association_name: 'Sportifs Solidaires' },
  { email: 'enfants@asso.fr',    password: 'password123', first_name: 'Sophie', last_name: 'Laurent', association_name: 'Les Petits Créateurs' },
  { email: 'theatre@asso.fr',    password: 'password123', first_name: 'Thomas', last_name: 'Bernard', association_name: 'Compagnie des Trois Actes' }
]

created_users = users_data.map do |ud|
  User.find_or_create_by!(email: ud[:email]) do |u|
    u.password = ud[:password]
    u.password_confirmation = ud[:password]
    u.first_name = ud[:first_name]
    u.last_name  = ud[:last_name]
    u.association_name = ud[:association_name]
  end
end
created_users << admin

# Désactive (provisoirement) un éventuel géocodage auto pour aller vite/offline.
re_enable_space_geocode = false
begin
  if defined?(Space) && Space.respond_to?(:skip_callback)
    Space.skip_callback(:validation, :after, :geocode)
    re_enable_space_geocode = true
  end
rescue => e
  puts "  (info) Impossible de désactiver le geocode: #{e.message}"
end

puts "== Espaces (30) =="
# Tu avais 2 espaces → on les garde et on en ajoute 28 pour atteindre 30.
spaces_seed = [
  # Tes 2 existants (catégories alignées par nom)
  { name:"Espace Créatif Montmartre", description:"Espace lumineux au cœur de Montmartre",
    address:"18 Rue des Abbesses, Paris", capacity:25, price_per_hour:45, latitude:48.8845, longitude:2.3322,
    category_name:"Ateliers créatifs" },

  { name:"Salle Confluence", description:"Grande salle à Lyon pour séminaires",
    address:"12 Cours Charlemagne, Lyon", capacity:60, price_per_hour:75, latitude:45.7464, longitude:4.8197,
    category_name:"Espaces événementiels" },

  # -------- Focus Nancy (12 env.) --------
  { name:"Salle de réunion Stanislas", address:"Place Stanislas, Nancy", capacity:12, price_per_hour:28, latitude:48.6937, longitude:6.1834, category_name:"Salles de réunion", description:"Salle calme près de la place Stanislas." },
  { name:"Espace atelier Carnot", address:"Rue Carnot, Nancy", capacity:18, price_per_hour:32, latitude:48.6929, longitude:6.1779, category_name:"Ateliers créatifs", description:"Atelier modulable et lumineux." },
  { name:"Studio événementiel Saint-Séb", address:"Rue Saint-Sébastien, Nancy", capacity:50, price_per_hour:65, latitude:48.6888, longitude:6.1879, category_name:"Espaces événementiels", description:"Idéal pour événements associatifs." },
  { name:"Salle de cours Artem", address:"Avenue du 20e Corps, Nancy", capacity:30, price_per_hour:40, latitude:48.6743, longitude:6.1610, category_name:"Salles de réunion", description:"Parfait pour formations." },
  { name:"Coworking Gare Nancy", address:"Avenue Foch, Nancy", capacity:24, price_per_hour:35, latitude:48.6897, longitude:6.1735, category_name:"Salles de réunion", description:"Espace partagé proche gare." },
  { name:"Salle polyvalente Rives de Meurthe", address:"Bd d’Austrasie, Nancy", capacity:80, price_per_hour:80, latitude:48.6912, longitude:6.2094, category_name:"Espaces événementiels", description:"Grand volume, facile d’accès." },
  { name:"Salle associative Pépinière", address:"Parc de la Pépinière, Nancy", capacity:20, price_per_hour:22, latitude:48.6960, longitude:6.1846, category_name:"Salles de réunion", description:"Cadre verdoyant." },
  { name:"Espace sportif Haussonville", address:"Bd d’Haussonville, Nancy", capacity:40, price_per_hour:30, latitude:48.6767, longitude:6.1608, category_name:"Espaces sportifs", description:"Salle claire pour activités sportives." },
  { name:"Atelier artistique Blandan", address:"Rue du Sergent Blandan, Nancy", capacity:16, price_per_hour:27, latitude:48.6880, longitude:6.1751, category_name:"Ateliers créatifs", description:"Atelier pour arts plastiques." },
  { name:"Salle quartier Trois-Maisons", address:"Rue du Faubourg des Trois Maisons, Nancy", capacity:25, price_per_hour:26, latitude:48.7002, longitude:6.1739, category_name:"Salles de réunion", description:"Conviviale, quartier vivant." },
  { name:"Espace conférence Mon Désert", address:"Rue Mon Désert, Nancy", capacity:60, price_per_hour:75, latitude:48.6826, longitude:6.1771, category_name:"Salles de réunion", description:"Configuration conférence." },
  { name:"Salle Charles III", address:"Rue Saint-Dizier, Nancy", capacity:15, price_per_hour:24, latitude:48.6903, longitude:6.1906, category_name:"Salles de réunion", description:"Salle simple et pratique." },

  # -------- Grand Est / voisins --------
  { name:"Salle Cathédrale", address:"Place d’Armes, Metz", capacity:12, price_per_hour:30, latitude:49.1191, longitude:6.1756, category_name:"Salles de réunion", description:"Centre historique de Metz." },
  { name:"Espace Gare Metz", address:"Place du Général de Gaulle, Metz", capacity:120, price_per_hour:110, latitude:49.1097, longitude:6.1778, category_name:"Espaces événementiels", description:"Très grande capacité." },
  { name:"Coworking Petite France", address:"Quai de la Bruche, Strasbourg", capacity:35, price_per_hour:38, latitude:48.5794, longitude:7.7396, category_name:"Salles de réunion", description:"Bords de l’Ill, très agréable." },
  { name:"Salle Mercière", address:"Rue Mercière, Strasbourg", capacity:18, price_per_hour:28, latitude:48.5814, longitude:7.7503, category_name:"Salles de réunion", description:"Proche cathédrale." },

  # -------- Ouest --------
  { name:"Espace réunion Bouffay", address:"Rue du Bouffay, Nantes", capacity:20, price_per_hour:34, latitude:47.2169, longitude:-1.5534, category_name:"Salles de réunion", description:"Quartier animé." },
  { name:"Salle Chantiers", address:"Île de Nantes", capacity:150, price_per_hour:140, latitude:47.2065, longitude:-1.5648, category_name:"Espaces événementiels", description:"Très grande salle polyvalente." },
  { name:"Coworking Capucins", address:"Ateliers des Capucins, Brest", capacity:28, price_per_hour:29, latitude:48.3897, longitude:-4.4958, category_name:"Salles de réunion", description:"Cadre industriel réhabilité." },
  { name:"Atelier Villejean", address:"Bd d’Antrain, Rennes", capacity:18, price_per_hour:27, latitude:48.1199, longitude:-1.6700, category_name:"Ateliers créatifs", description:"Parfait ateliers créatifs." },

  # -------- Sud-Ouest / Centre / Sud-Est --------
  { name:"Salle Saint-Michel", address:"Quai des Salinières, Bordeaux", capacity:70, price_per_hour:85, latitude:44.8349, longitude:-0.5667, category_name:"Salles de réunion", description:"Vue sur Garonne." },
  { name:"Espace Esquirol", address:"Place Esquirol, Toulouse", capacity:22, price_per_hour:33, latitude:43.6008, longitude:1.4420, category_name:"Salles de réunion", description:"Hyper centre." },
  { name:"Studio Prado", address:"Avenue du Prado, Marseille", capacity:90, price_per_hour:95, latitude:43.2806, longitude:5.3875, category_name:"Espaces événementiels", description:"Idéal expo et rencontres." },
  { name:"Coworking Part-Dieu", address:"Bd Vivier-Merle, Lyon", capacity:40, price_per_hour:42, latitude:45.7601, longitude:4.8589, category_name:"Salles de réunion", description:"Proche gare Part-Dieu." },
  { name:"Atelier Croix-Rousse", address:"Bd de la Croix-Rousse, Lyon", capacity:15, price_per_hour:28, latitude:45.7740, longitude:4.8270, category_name:"Ateliers créatifs", description:"Ambiance atelier." },
  { name:"Salle Promenade du Paillon", address:"Promenade du Paillon, Nice", capacity:16, price_per_hour:31, latitude:43.7010, longitude:7.2719, category_name:"Salles de réunion", description:"Clair et central." },
  { name:"Espace Comédie", address:"Place de la Comédie, Montpellier", capacity:24, price_per_hour:32, latitude:43.6070, longitude:3.8796, category_name:"Salles de réunion", description:"Hyper centre." },
  { name:"Salle Victor Hugo", address:"Bd Gambetta, Grenoble", capacity:55, price_per_hour:60, latitude:45.1860, longitude:5.7245, category_name:"Salles de réunion", description:"Grande salle formation." }
]

spaces_seed.each do |h|
  Space.create!(
    name: h[:name],
    description: h[:description] || "Bel espace associatif.",
    address: h[:address],
    capacity: h[:capacity],
    price_per_hour: h[:price_per_hour].to_f,
    latitude: h[:latitude],
    longitude: h[:longitude],
    category: cats_by_name[h[:category_name]]
  )
end
puts "  -> #{Space.count} espaces créés."

# Réactive le géocodage si désactivé
begin
  Space.set_callback(:validation, :after, :geocode) if re_enable_space_geocode
rescue => e
  puts "  (info) Impossible de réactiver le geocode: #{e.message}"
end

puts "== Besoins =="
# On reprend ta liste (27) et on ajoute 3 besoins pour arriver à 30.
needs = [
  # --- Paris / IDF ---
  { title:"Recherche salle pour répétition théâtrale", description:"La Compagnie des Trois Actes cherche une salle pour répéter.", category:"atelier",
    address:"25 rue des Martyrs", city:"Paris", postal_code:"75009", country:"France", capacity:15, date_needed:2.weeks.from_now,
    start_time:"18:00", end_time:"21:00", budget:50, recurrence:"weekly", latitude:48.8763, longitude:2.3397,
    equipment_needs:["système son","chaises","espace dégagé"] },

  { title:"Local pour cours de danse contemporaine", description:"Studio avec parquet/lino, miroirs appréciés.", category:"atelier",
    address:"14 rue de la Roquette", city:"Paris", postal_code:"75011", country:"France", capacity:20, date_needed:10.days.from_now,
    start_time:"19:30", end_time:"21:30", budget:40, recurrence:"weekly", latitude:48.8534, longitude:2.3709,
    equipment_needs:["miroirs","système son"] },

  { title:"Recherche salle pour réunion mensuelle", description:"Réunions CA + petites confs.", category:"réunion",
    address:"5 avenue Daumesnil", city:"Paris", postal_code:"75012", country:"France", capacity:25, date_needed:3.weeks.from_now,
    start_time:"14:00", end_time:"17:00", budget:60, recurrence:"monthly", latitude:48.8423, longitude:2.3825,
    equipment_needs:["vidéoprojecteur","tables","chaises","wifi"] },

  { title:"Atelier d'arts plastiques pour enfants", description:"Ateliers 6–12 ans. Point d’eau nécessaire.", category:"atelier",
    address:"18 rue des Lilas", city:"Montreuil", postal_code:"93100", country:"France", capacity:15, date_needed:2.weeks.from_now,
    start_time:"14:00", end_time:"16:30", budget:45, recurrence:"weekly", latitude:48.8636, longitude:2.4349,
    equipment_needs:["tables","point d'eau","éclairage naturel"] },

  { title:"Salle pour conférence écologique", description:"Projection + débat. Accès facile.", category:"événement",
    address:"10 rue Victor Hugo", city:"Saint-Denis", postal_code:"93200", country:"France", capacity:80, date_needed:1.month.from_now,
    start_time:"18:30", end_time:"22:00", budget:200, recurrence:"once", latitude:48.9362, longitude:2.3540,
    equipment_needs:["vidéoprojecteur","sonorisation","micro","chaises"] },

  # --- Lyon ---
  { title:"Local pour cours de yoga", description:"Hatha Yoga hebdo. Accessibilité PMR.", category:"sport",
    address:"25 rue de la République", city:"Lyon", postal_code:"69001", country:"France", capacity:15, date_needed:2.weeks.from_now,
    start_time:"18:00", end_time:"20:00", budget:35, recurrence:"weekly", latitude:45.767, longitude:4.836,
    equipment_needs:["chauffage","espace dégagé"] },

  { title:"Atelier cuisine participative", description:"Cuisine équipée/semi-pro.", category:"atelier",
    address:"5 place Bellecour", city:"Lyon", postal_code:"69002", country:"France", capacity:12, date_needed:3.weeks.from_now,
    start_time:"10:00", end_time:"14:00", budget:100, recurrence:"monthly", latitude:45.7578, longitude:4.8327,
    equipment_needs:["cuisine équipée","réfrigérateur","plan de travail"] },

  { title:"Répétition de chorale", description:"Bonne acoustique indispensable.", category:"atelier",
    address:"15 rue de la Part-Dieu", city:"Lyon", postal_code:"69003", country:"France", capacity:25, date_needed:10.days.from_now,
    start_time:"20:00", end_time:"22:00", budget:40, recurrence:"weekly", latitude:45.7605, longitude:4.8564,
    equipment_needs:["piano","chaises","pupitre"] },

  # --- Marseille ---
  { title:"Espace pour exposition photo", description:"Éclairage adapté et cimaises.", category:"événement",
    address:"25 rue Paradis", city:"Marseille", postal_code:"13001", country:"France", capacity:50, date_needed:2.months.from_now,
    start_time:"10:00", end_time:"19:00", budget:350, recurrence:"once", latitude:43.2967, longitude:5.3764,
    equipment_needs:["éclairage","cimaises","tables d'accueil"] },

  { title:"Salle pour conférence médicale", description:"Conférence avec 3 médecins.", category:"événement",
    address:"9 boulevard Michelet", city:"Marseille", postal_code:"13008", country:"France", capacity:100, date_needed:6.weeks.from_now,
    start_time:"14:00", end_time:"18:00", budget:250, recurrence:"once", latitude:43.2692, longitude:5.3855,
    equipment_needs:["sonorisation","vidéoprojecteur","micros","chaises"] },

  # --- Bordeaux ---
  { title:"Espace pour ateliers d'écriture", description:"Lieu calme/inspirant.", category:"atelier",
    address:"12 rue Sainte-Catherine", city:"Bordeaux", postal_code:"33000", country:"France", capacity:15, date_needed:3.weeks.from_now,
    start_time:"16:00", end_time:"19:00", budget:60, recurrence:"biweekly", latitude:44.8412, longitude:-0.5731,
    equipment_needs:["tables","chaises","tableau"] },

  { title:"Local pour ateliers musicaux", description:"Découverte instruments.", category:"atelier",
    address:"25 quai des Chartrons", city:"Bordeaux", postal_code:"33000", country:"France", capacity:20, date_needed:1.month.from_now,
    start_time:"14:00", end_time:"17:00", budget:80, recurrence:"weekly", latitude:44.8520, longitude:-0.5648,
    equipment_needs:["isolation phonique","prises électriques","chaises"] },

  # --- Lille ---
  { title:"Salle pour assemblée générale", description:"AG annuelle ~40 pers.", category:"réunion",
    address:"5 place Rihour", city:"Lille", postal_code:"59000", country:"France", capacity:50, date_needed:2.months.from_now,
    start_time:"18:30", end_time:"21:00", budget:120, recurrence:"once", latitude:50.6374, longitude:3.0619,
    equipment_needs:["vidéoprojecteur","micro","tables","chaises"] },

  { title:"Espace sportif pour boxe éducative", description:"Cours ados, espace dégagé.", category:"sport",
    address:"10 rue Nationale", city:"Lille", postal_code:"59000", country:"France", capacity:15, date_needed:3.weeks.from_now,
    start_time:"17:00", end_time:"19:00", budget:50, recurrence:"weekly", latitude:50.6305, longitude:3.0710,
    equipment_needs:["espace dégagé","tapis de sol","vestiaires"] },

  # --- Nantes ---
  { title:"Lieu pour festival associatif", description:"Int/Ext si possible.", category:"événement",
    address:"2 rue de la Paix", city:"Nantes", postal_code:"44000", country:"France", capacity:150, date_needed:3.months.from_now,
    start_time:"10:00", end_time:"22:00", budget:500, recurrence:"once", latitude:47.2139, longitude:-1.5551,
    equipment_needs:["sonorisation","éclairage","tables","chaises","accès eau et électricité"] },

  { title:"Local pour ateliers de sensibilisation", description:"Prévention santé, jeunes.", category:"atelier",
    address:"15 boulevard Guist'hau", city:"Nantes", postal_code:"44000", country:"France", capacity:30, date_needed:1.month.from_now,
    start_time:"13:30", end_time:"16:30", budget:70, recurrence:"monthly", latitude:47.2227, longitude:-1.5606,
    equipment_needs:["connexion internet","tables en îlots"] },

  # --- Nancy (10) ---
  { title:"Salle pour cours de théâtre amateur", description:"Troupe 12 comédiens.", category:"atelier",
    address:"10 rue Saint-Dizier", city:"Nancy", postal_code:"54000", country:"France", capacity:15, date_needed:2.weeks.from_now,
    start_time:"19:00", end_time:"22:00", budget:60, recurrence:"weekly", latitude:48.6921, longitude:6.1844,
    equipment_needs:["espace dégagé","chaises","quelques accessoires"] },

  { title:"Local pour atelier d'art-thérapie", description:"Groupe restreint, calme.", category:"atelier",
    address:"25 rue des Dominicains", city:"Nancy", postal_code:"54000", country:"France", capacity:10, date_needed:3.weeks.from_now,
    start_time:"14:00", end_time:"16:30", budget:45, recurrence:"weekly", latitude:48.6897, longitude:6.1803,
    equipment_needs:["tables","point d'eau","éclairage de qualité"] },

  { title:"Conférence histoire locale", description:"Patrimoine lorrain + archives.", category:"événement",
    address:"8 place Stanislas", city:"Nancy", postal_code:"54000", country:"France", capacity:60, date_needed:1.month.from_now,
    start_time:"18:00", end_time:"20:30", budget:150, recurrence:"once", latitude:48.6936, longitude:6.1832,
    equipment_needs:["vidéoprojecteur","sonorisation","chaises","podium"] },

  { title:"Salle pour chorale gospel", description:"25 personnes, acoustique.", category:"atelier",
    address:"15 rue Gustave Simon", city:"Nancy", postal_code:"54000", country:"France", capacity:30, date_needed:2.weeks.from_now,
    start_time:"20:00", end_time:"22:00", budget:50, recurrence:"weekly", latitude:48.6917, longitude:6.1870,
    equipment_needs:["piano ou clavier","chaises","bonne acoustique"] },

  { title:"Ateliers jeux de société", description:"Après-midis & soirées.", category:"loisirs",
    address:"30 rue Raymond Poincaré", city:"Nancy", postal_code:"54000", country:"France", capacity:25, date_needed:10.days.from_now,
    start_time:"14:00", end_time:"22:00", budget:80, recurrence:"biweekly", latitude:48.6858, longitude:6.1738,
    equipment_needs:["tables larges","chaises confortables","éclairage adapté"] },

  { title:"Cours de cuisine diététique", description:"Cuisine équipée souhaitée.", category:"atelier",
    address:"12 rue Sainte-Catherine", city:"Nancy", postal_code:"54000", country:"France", capacity:12, date_needed:3.weeks.from_now,
    start_time:"17:30", end_time:"20:30", budget:100, recurrence:"weekly", latitude:48.6886, longitude:6.1791,
    equipment_needs:["cuisine équipée","plan de travail","réfrigérateur"] },

  { title:"Brocante associative", description:"Grand espace couvert 1 journée.", category:"événement",
    address:"5 boulevard d'Austrasie", city:"Nancy", postal_code:"54000", country:"France", capacity:150, date_needed:2.months.from_now,
    start_time:"08:00", end_time:"18:00", budget:300, recurrence:"once", latitude:48.6945, longitude:6.2024,
    equipment_needs:["tables","chaises","accès camion","toilettes"] },

  { title:"AG annuelle – aide aux aînés", description:"Accessible PMR ~40 pers.", category:"réunion",
    address:"20 rue de la Ravinelle", city:"Nancy", postal_code:"54000", country:"France", capacity:50, date_needed:6.weeks.from_now,
    start_time:"16:00", end_time:"19:00", budget:120, recurrence:"once", latitude:48.6882, longitude:6.1753,
    equipment_needs:["vidéoprojecteur","micros","accessibilité PMR","tables"] },

  { title:"Ateliers jeunesse périscolaire", description:"7–12 ans, créatif/ludique.", category:"atelier",
    address:"8 rue Cyfflé", city:"Nancy", postal_code:"54000", country:"France", capacity:15, date_needed:2.weeks.from_now,
    start_time:"16:30", end_time:"18:30", budget:40, recurrence:"weekly", latitude:48.6909, longitude:6.1882,
    equipment_needs:["tables adaptées enfants","point d'eau","rangements"] },

  { title:"Projection-débat documentaire", description:"Ciné-club associatif.", category:"événement",
    address:"3 rue Victor Hugo", city:"Nancy", postal_code:"54000", country:"France", capacity:40, date_needed:1.month.from_now,
    start_time:"19:00", end_time:"22:30", budget:90, recurrence:"monthly", latitude:48.6876, longitude:6.1829,
    equipment_needs:["système de projection","sonorisation","obscurcissement","chaises"] },

  # --- Rennes ---
  { title:"Concert caritatif", description:"3 groupes locaux, bénéfices reversés.", category:"événement",
    address:"15 rue Saint-Michel", city:"Rennes", postal_code:"35000", country:"France", capacity:120, date_needed:2.months.from_now,
    start_time:"19:00", end_time:"23:30", budget:350, recurrence:"once", latitude:48.1138, longitude:-1.6810,
    equipment_needs:["scène","sonorisation","éclairage","loges"] },

  # --- 3 besoins supplémentaires pour atteindre 30 ---
  { title:"Stage théâtre ados", description:"Recherche salle 5 après-midis.", category:"atelier",
    address:"Rue des Dominicains", city:"Nancy", postal_code:"54000", country:"France", capacity:14, date_needed:3.weeks.from_now,
    start_time:"14:00", end_time:"17:30", budget:70, recurrence:"once", latitude:48.6899, longitude:6.1820,
    equipment_needs:["chaises","espace dégagé"] },

  { title:"Forum des assos – mini stands", description:"Besoin d’un espace couvert modulable.", category:"événement",
    address:"Cours Léopold", city:"Nancy", postal_code:"54000", country:"France", capacity:200, date_needed:6.weeks.from_now,
    start_time:"10:00", end_time:"18:00", budget:400, recurrence:"once", latitude:48.6962, longitude:6.1770,
    equipment_needs:["tables","chaises","électricité"] },

  { title:"Réunion inter-asso", description:"Réunion de coordination trimestrielle.", category:"réunion",
    address:"Rue Saint-Jean", city:"Nancy", postal_code:"54000", country:"France", capacity:30, date_needed:1.month.from_now,
    start_time:"18:30", end_time:"20:30", budget:80, recurrence:"quarterly", latitude:48.6902, longitude:6.1765,
    equipment_needs:["vidéoprojecteur","wifi"] }
]

created = 0

def fake_fr_mobile(i)
  # génère un numéro fictif au format français
  base = i % 10
  "06 42 3#{base} 7#{base} 9#{base}"
end

needs.each_with_index do |data, idx|
  n = Need.new(data)

  # Associe un user
  n.user = created_users[idx % created_users.length] if n.respond_to?(:user=)

  # Ajoute automatiquement contact_email / contact_phone
  n.contact_email ||= (n.user&.email || "contact#{idx}@lelocal.test")
  n.contact_phone ||= fake_fr_mobile(idx)

  if n.save
    puts "  ✓ Besoin créé: #{n.title}"
    created += 1
  else
    puts "  ✗ Besoin KO: #{n.errors.full_messages.join(', ')}"
  end
end

puts "  -> #{created} besoins créés."

# -- Attach sample photos to spaces (up to 3) --
require 'open-uri'

SAMPLE_SPACE_PHOTOS = [
  "https://images.unsplash.com/photo-1524758631624-e2822e304c36?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1520880867055-1e30d1cb001c?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1503602642458-232111445657?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1582582494700-0aea3b1b6a4e?q=80&w=1200&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1554995207-c18c203602cb?q=80&w=1200&auto=format&fit=crop"
]

puts "== Photos des espaces =="
Space.find_each do |sp|
  next if sp.photos.attached?
  SAMPLE_SPACE_PHOTOS.sample(3).each_with_index do |url, idx|
    URI.open(url) do |io|
      sp.photos.attach(io: io, filename: "space_#{sp.id}_#{idx+1}.jpg", content_type: "image/jpeg")
    end
  end
  sp.save!
  puts "  -> photos attachées à #{sp.name}"
rescue => e
  puts "  !! #{sp.name} : #{e.class} #{e.message}"
end


puts "== Photos des espaces =="

require "open-uri"

# Banque d'images stables (picsum.photos suit les redirections et reste fiable)
PICSUM_IDS = %w[
  1011 1015 1025 1035 1043 1050 1067 1077 1084 1080
  110  237  238  239  240  241  242  243  244  245
]
def picsum_urls(n)
  PICSUM_IDS.sample(n).map { |id| "https://picsum.photos/id/\#{id}/1200/800.jpg" }
end

def attach_photo_from_url!(record, url, idx)
  URI.parse(url).open(read_timeout: 15) do |io|
    record.photos.attach(
      io: io,
      filename: "space_\#{record.id}_\#{idx+1}.jpg",
      content_type: "image/jpeg"
    )
  end
end

Space.find_each do |sp|
  next if sp.photos.attached?

  urls = picsum_urls(3)
  attached = 0

  urls.each_with_index do |u, i|
    begin
      attach_photo_from_url!(sp, u, i)
      attached += 1
    rescue => e
      puts "  !! \#{sp.name} : \#{e.class} \#{e.message} (URL: \#{u})"
      # Fallback immédiat : autre id
      begin
        alt = picsum_urls(1).first
        attach_photo_from_url!(sp, alt, i)
        attached += 1
      rescue => e2
        puts "  .. fallback KO pour \#{sp.name} : \#{e2.class} \#{e2.message}"
      end
    end
  end

  if attached > 0
    sp.save!
    puts "  -> photos attachées à \#{sp.name} (\#{attached})"
  else
    puts "  xx aucune photo attachée à \#{sp.name}"
  end
end

# --- Featured spaces for homepage ---
# --- Featured spaces for homepage ---
require "open-uri"

featured = [
  {
    name:  "Espace Créatif Montmartre",
    address: "18 Rue Gabrielle, 75018 Paris",
    capacity: 25,
    price_per_hour: 45,
    category: Category.find_by(name: "Atelier") || Category.first,
    latitude: 48.8867, longitude: 2.3425,
    photos: [
      "https://images.unsplash.com/photo-1526318472351-c75fcf070305?w=1600&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1600461601623-5e995b2d2e1f?w=1600&auto=format&fit=crop"
    ]
  },
  {
    name:  "Atelier Artistique Bastille",
    address: "12 Rue de la Roquette, 75011 Paris",
    capacity: 15,
    price_per_hour: 35,
    category: Category.find_by(name: "Atelier") || Category.first,
    latitude: 48.8531, longitude: 2.3710,
    photos: [
      "https://images.unsplash.com/photo-1498887960847-2a5e46312788?w=1600&auto=format&fit=crop",
      "https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1600&auto=format&fit=crop"
    ]
  },
  {
    name:  "Salle Panoramique République",
    address: "24 Bd Saint-Martin, 75010 Paris",
    capacity: 40,
    price_per_hour: 60,
    category: Category.find_by(name: "Salle d'événement") || Category.first,
    latitude: 48.8680, longitude: 2.3630,
    photos: [
      "https://images.unsplash.com/photo-1577412647305-991150c7d163?w=1600&auto=format&fit=crop"
    ]
  }
]

featured.each do |attrs|
  space = Space.find_or_initialize_by(name: attrs[:name])
  space.assign_attributes(
    description:    "#{attrs[:name]} — espace mis en avant.",
    address:        attrs[:address],
    capacity:       attrs[:capacity],
    price_per_hour: attrs[:price_per_hour],
    category:       attrs[:category],
    latitude:       attrs[:latitude],
    longitude:      attrs[:longitude]
  )
  space.save!

  if space.photos.blank?
    attrs[:photos].each_with_index do |url, i|
      begin
        file = URI.open(url)
        space.photos.attach(io: file, filename: "#{space.name.parameterize}-#{i+1}.jpg", content_type: "image/jpeg")
      rescue OpenURI::HTTPError => e
        puts "⚠️  Impossible de télécharger #{url} : #{e.message}"
        fallback = URI.open("https://via.placeholder.com/800x600?text=#{CGI.escape(space.name)}")
        space.photos.attach(io: fallback, filename: "#{space.name.parameterize}-fallback.jpg", content_type: "image/jpeg")
      end
    end
    puts "  -> photos attachées à #{space.name}"
  end
end

