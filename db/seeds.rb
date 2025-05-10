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
  u.association_name = 'Les Lilas de la rue Mortier'  # 👈 ici, et seulement ici
end

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
  {
    title: "Recherche salle pour répétition",
    description: "Nous cherchons une salle pour des répétitions de théâtre.",
    category: "atelier",
    address: "25 rue de la République",
    city: "Lyon",
    postal_code: "69001",
    country: "France",
    capacity: 15,
    date_needed: 2.weeks.from_now,
    start_time: "18:00",
    end_time: "21:00",
    budget: 50,
    recurrence: "weekly",
    latitude: 45.767,
    longitude: 4.836,
    equipment_needs: ["videoprojecteur", "son"]
  }
]

created = 0
needs.each do |need_data|
  need = Need.new(need_data)
  need.user = user  # ✅ C’est ici qu'on lie l'association via l'utilisateur
  if need.save
    puts "✅ Besoin créé : #{need.title}"
    created += 1
  else
    puts "❌ Erreur : #{need.errors.full_messages.join(', ')}"
  end
end

puts "Seeding terminé avec succès. #{created} besoin(s) créé(s)."
