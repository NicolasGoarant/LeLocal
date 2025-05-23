<% content_for :head do %>
    <style>
      /* Styles pour la page "Proposer un espace" */
      .host-section {
        padding: 60px 0;
        background-color: #f8f9fa;
      }
      
      .host-header {
        text-align: center;
        margin-bottom: 50px;
      }
      
      .host-header h1 {
        font-size: 2.5rem;
        margin-bottom: 15px;
        color: #333;
      }
      
      .host-header .subtitle {
        font-size: 1.2rem;
        color: #666;
        max-width: 600px;
        margin: 0 auto;
      }
      
      .host-benefits {
        display: flex;
        justify-content: space-between;
        margin-bottom: 60px;
        flex-wrap: wrap;
      }
      
      .benefit-card {
        background-color: white;
        border-radius: 10px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        padding: 30px;
        width: 30%;
        text-align: center;
        transition: transform 0.3s;
      }
      
      .benefit-card:hover {
        transform: translateY(-5px);
      }
      
      .benefit-icon {
        background-color: var(--primary-color, #4CAF50);
        color: white;
        width: 70px;
        height: 70px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        font-size: 24px;
      }
      
      .benefit-card h3 {
        margin-bottom: 10px;
        color: #333;
      }
      
      .benefit-card p {
        color: #666;
        font-size: 0.95rem;
      }
      
      .host-steps {
        margin-bottom: 60px;
      }
      
      .host-steps h2 {
        text-align: center;
        margin-bottom: 30px;
        color: #333;
      }
      
      .step-container {
        display: flex;
        justify-content: space-between;
        flex-wrap: wrap;
      }
      
      .step {
        display: flex;
        align-items: center;
        width: 48%;
        margin-bottom: 30px;
      }
      
      .step-number {
        background-color: var(--primary-color, #4CAF50);
        color: white;
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        font-weight: bold;
        margin-right: 20px;
        flex-shrink: 0;
      }
      
      .step-content h3 {
        margin-bottom: 5px;
        color: #333;
      }
      
      .step-content p {
        color: #666;
        font-size: 0.95rem;
      }
      
      /* Styles pour le formulaire */
      .host-form-container {
        background-color: white;
        border-radius: 10px;
        box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
        padding: 40px;
        margin-bottom: 60px;
      }
      
      .host-form-container h2 {
        text-align: center;
        margin-bottom: 10px;
        color: #333;
      }
      
      .form-intro {
        text-align: center;
        color: #666;
        margin-bottom: 30px;
      }
      
      .form-section {
        margin-bottom: 35px;
        border-bottom: 1px solid #eee;
        padding-bottom: 30px;
      }
      
      .form-section:last-of-type {
        border-bottom: none;
      }
      
      .form-section h3 {
        margin-bottom: 20px;
        color: #333;
        font-size: 1.2rem;
      }
      
      .section-hint {
        color: #777;
        font-size: 0.9rem;
        margin-bottom: 15px;
      }
      
      .form-group {
        margin-bottom: 20px;
      }
      
      .form-row {
        display: flex;
        gap: 20px;
        margin-bottom: 20px;
      }
      
      .form-group.half {
        width: 48%;
      }
      
      .form-group label {
        display: block;
        margin-bottom: 8px;
        color: #555;
        font-weight: 500;
      }
      
      .form-group input[type="text"],
      .form-group input[type="number"],
      .form-group input[type="email"],
      .form-group textarea,
      .form-group select {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 5px;
        font-size: 1rem;
        transition: border-color 0.3s;
      }
      
      .form-group input[type="text"]:focus,
      .form-group input[type="number"]:focus,
      .form-group input[type="email"]:focus,
      .form-group textarea:focus,
      .form-group select:focus {
        border-color: var(--primary-color, #4CAF50);
        outline: none;
      }
      
      .price-input {
        position: relative;
      }
      
      .price-currency {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #777;
      }
      
      /* Styles pour l'upload d'images */
      .image-upload-container {
        display: flex;
        align-items: center;
        gap: 20px;
        margin-bottom: 15px;
      }
      
      .image-upload-button {
        display: flex;
        align-items: center;
        gap: 10px;
        background-color: #f5f5f5;
        border: 1px dashed #ccc;
        border-radius: 5px;
        padding: 12px 20px;
        cursor: pointer;
        transition: background-color 0.3s;
      }
      
      .image-upload-button:hover {
        background-color: #eaeaea;
      }
      
      .image-upload-button i {
        font-size: 1.2rem;
        color: #666;
      }
      
      .hidden-file-input {
        display: none;
      }
      
      .image-upload-hint p {
        color: #777;
        font-size: 0.85rem;
      }
      
      .image-previews {
        display: flex;
        flex-wrap: wrap;
        gap: 15px;
        margin-top: 20px;
      }
      
      .image-preview {
        position: relative;
        width: 120px;
        height: 120px;
        border-radius: 5px;
        overflow: hidden;
      }
      
      .image-preview img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      
      .remove-image {
        position: absolute;
        top: 5px;
        right: 5px;
        width: 24px;
        height: 24px;
        border-radius: 50%;
        background-color: rgba(0, 0, 0, 0.6);
        color: white;
        border: none;
        font-size: 16px;
        line-height: 1;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
      }
      
      /* Styles pour les disponibilités */
      .availability-container {
        border: 1px solid #ddd;
        border-radius: 5px;
      }
      
      .availability-header {
        display: grid;
        grid-template-columns: 1fr 1fr 2fr;
        padding: 12px 15px;
        background-color: #f5f5f5;
        border-bottom: 1px solid #ddd;
        font-weight: 500;
      }
      
      .availability-row {
        display: grid;
        grid-template-columns: 1fr 1fr 2fr;
        padding: 12px 15px;
        border-bottom: 1px solid #eee;
        align-items: center;
      }
      
      .availability-row:last-child {
        border-bottom: none;
      }
      
      .day-name {
        font-weight: 500;
      }
      
      .availability-toggle {
        text-align: center;
      }
      
      .toggle-switch {
        position: relative;
        display: inline-block;
        width: 50px;
        height: 24px;
        background-color: #ccc;
        border-radius: 12px;
        cursor: pointer;
        transition: background-color 0.3s;
      }
      
      .toggle-switch:after {
        content: '';
        position: absolute;
        top: 2px;
        left: 2px;
        width: 20px;
        height: 20px;
        background-color: white;
        border-radius: 50%;
        transition: left 0.3s;
      }
      
      .availability-checkbox {
        display: none;
      }
      
      .availability-checkbox:checked + .toggle-switch {
        background-color: var(--primary-color, #4CAF50);
      }
      
      .availability-checkbox:checked + .toggle-switch:after {
        left: 28px;
      }
      
      .time-range {
        display: flex;
        align-items: center;
        gap: 10px;
      }
      
      .time-select {
        flex: 1;
        padding: 8px 10px;
        border: 1px solid #ddd;
        border-radius: 5px;
      }
      
      .time-separator {
        font-weight: 500;
      }
      
      /* Styles pour les équipements */
      .amenities-container {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 30px;
      }
      
      .amenity-group h4 {
        margin-bottom: 15px;
        color: #555;
      }
      
      .amenity-checkboxes {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
      }
      
      .amenity-checkbox {
        display: flex;
        align-items: center;
        gap: 8px;
      }
      
      .amenity-checkbox input[type="checkbox"] {
        width: 18px;
        height: 18px;
        accent-color: var(--primary-color, #4CAF50);
      }
      
      /* Styles pour les termes et conditions */
      .terms-agreement {
        margin-bottom: 30px;
      }
      
      .form-checkbox {
        display: flex;
        align-items: flex-start;
        gap: 10px;
      }
      
      .form-checkbox input[type="checkbox"] {
        margin-top: 3px;
      }
      
      .form-checkbox label {
        font-size: 0.95rem;
        color: #555;
      }
      
      .form-checkbox a {
        color: var(--primary-color, #4CAF50);
        text-decoration: underline;
      }
      
      /* Styles pour les boutons du formulaire */
      .form-actions {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin-top: 40px;
      }
      
      .btn-large {
        padding: 15px 30px;
        border-radius: 30px;
        font-size: 1.1rem;
        font-weight: bold;
        text-decoration: none;
        transition: all 0.3s;
        border: none;
        cursor: pointer;
        display: inline-block;
      }
      
      .btn-large.primary {
        background-color: var(--primary-color, #4CAF50);
        color: white;
      }
      
      .btn-large.secondary {
        background-color: #eee;
        color: #555;
      }
      
      .btn-large.primary:hover {
        background-color: #3d8b3d;
      }
      
      .btn-large.secondary:hover {
        background-color: #ddd;
      }
      
      /* Styles pour les FAQ */
      .host-faq {
        margin-top: 60px;
      }
      
      .host-faq h2 {
        text-align: center;
        margin-bottom: 30px;
        color: #333;
      }
      
      .faq-container {
        max-width: 800px;
        margin: 0 auto;
      }
      
      .faq-item {
        border-bottom: 1px solid #e0e0e0;
        margin-bottom: 15px;
      }
      
      .faq-question {
        padding: 15px 0;
        display: flex;
        justify-content: space-between;
        align-items: center;
        cursor: pointer;
      }
      
      .faq-question h3 {
        margin: 0;
        font-size: 1.1rem;
        color: #333;
      }
      
      .faq-toggle {
        font-size: 1.5rem;
        color: var(--primary-color, #4CAF50);
      }
      
      .faq-answer {
        padding: 0 0 15px;
        color: #666;
      }
      
      /* Responsive styles */
      @media (max-width: 992px) {
        .benefit-card {
          width: 48%;
          margin-bottom: 20px;
        }
        
        .amenities-container {
          grid-template-columns: 1fr;
        }
      }
      
      @media (max-width: 768px) {
        .benefit-card, .step {
          width: 100%;
        }
        
        .form-row {
          flex-direction: column;
          gap: 15px;
        }
        
        .form-group.half {
          width: 100%;
        }
        
        .form-actions {
          flex-direction: column;
          gap: 15px;
        }
        
        .availability-header, .availability-row {
          grid-template-columns: 1fr;
          gap: 10px;
        }
        
        .availability-status-header, .time-header {
          display: none;
        }
        
        .amenity-checkboxes {
          grid-template-columns: 1fr;
        }
      }
      
      @media (max-width: 480px) {
        .host-header h1 {
          font-size: 2rem;
        }
        
        .host-form-container {
          padding: 25px 15px;
        }
      }
      
      /* Définir la couleur primaire */
      :root {
        --primary-color: #4CAF50;
      }
      
      /* Ajout de style pour le container */
      .container {
        width: 100%;
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 15px;
      }
    </style>
  <% end %>
  
  <% content_for :title, "LeLocal - Proposer un espace" %>
  
  <section class="host-section">
    <div class="container">
      <div class="host-header">
        <h1>Proposer votre espace sur LeLocal</h1>
        <p class="subtitle">Partagez votre espace avec la communauté et générez des revenus supplémentaires</p>
      </div>
      
      <div class="host-benefits">
        <div class="benefit-card">
          <div class="benefit-icon">
            <i class="fas fa-euro-sign"></i>
          </div>
          <h3>Générez des revenus</h3>
          <p>Rentabilisez votre espace en le louant lorsque vous ne l'utilisez pas</p>
        </div>
        
        <div class="benefit-card">
          <div class="benefit-icon">
            <i class="fas fa-calendar-alt"></i>
          </div>
          <h3>Flexibilité totale</h3>
          <p>Définissez vos propres disponibilités et tarifs selon vos besoins</p>
        </div>
        
        <div class="benefit-card">
          <div class="benefit-icon">
            <i class="fas fa-shield-alt"></i>
          </div>
          <h3>Sécurité garantie</h3>
          <p>Nos utilisateurs sont vérifiés et notre assurance couvre les dommages éventuels</p>
        </div>
      </div>
      
      <div class="host-steps">
        <h2>Comment ça marche ?</h2>
        
        <div class="step-container">
          <div class="step">
            <div class="step-number">1</div>
            <div class="step-content">
              <h3>Créez votre annonce</h3>
              <p>Décrivez votre espace, ajoutez des photos et définissez vos tarifs</p>
            </div>
          </div>
          
          <div class="step">
            <div class="step-number">2</div>
            <div class="step-content">
              <h3>Recevez des réservations</h3>
              <p>Les utilisateurs peuvent voir votre annonce et réserver votre espace</p>
            </div>
          </div>
          
          <div class="step">
            <div class="step-number">3</div>
            <div class="step-content">
              <h3>Accueillez vos clients</h3>
              <p>Accueillez les utilisateurs et proposez-leur une expérience agréable</p>
            </div>
          </div>
          
          <div class="step">
            <div class="step-number">4</div>
            <div class="step-content">
              <h3>Recevez votre paiement</h3>
              <p>Recevez votre paiement 24h après la fin de la réservation</p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="host-form-container">
        <h2>Créer votre annonce</h2>
        <p class="form-intro">Remplissez le formulaire ci-dessous pour proposer votre espace</p>
        
        <%= form_with(model: @space, url: spaces_path, class: "host-form", local: true, multipart: true) do |form| %>
          <% if @space.errors.any? %>
            <div class="form-errors">
              <h3><%= pluralize(@space.errors.count, "erreur") %> empêche(nt) la sauvegarde de votre espace :</h3>
              <ul>
                <% @space.errors.full_messages.each do |message| %>
                  <li><%= message %></li>
                <% end %>
              </ul>
            </div>
          <% end %>
          
          <div class="form-section">
            <h3>Informations générales</h3>
            
            <div class="form-group">
              <%= form.label :name, "Nom de l'espace" %>
              <%= form.text_field :name, placeholder: "Ex: Atelier créatif Saint-Michel", required: true %>
            </div>
            
            <div class="form-group">
              <%= form.label :description, "Description" %>
              <%= form.text_area :description, rows: 5, placeholder: "Décrivez votre espace en détail : ambiance, équipements, particularités...", required: true %>
            </div>
            
            <div class="form-group">
              <%= form.label :category, "Catégorie" %>
              <%= form.select :category, [
                ["Salle de réunion", "meeting_room"],
                ["Espace de coworking", "coworking"],
                ["Atelier créatif", "creative_studio"],
                ["Salle de formation", "training_room"],
                ["Espace événementiel", "event_space"],
                ["Studio photo/vidéo", "photo_studio"],
                ["Espace culturel", "cultural_space"],
                ["Autre", "other"]
              ], { include_blank: "Sélectionnez une catégorie" }, { required: true } %>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Localisation</h3>
            
            <div class="form-group">
              <%= form.label :address, "Adresse complète" %>
              <%= form.text_field :address, placeholder: "Ex: 15 Rue des Lilas, 75019 Paris", required: true %>
            </div>
            
            <div class="form-row">
              <div class="form-group half">
                <%= form.label :city, "Ville" %>
                <%= form.text_field :city, placeholder: "Ex: Paris", required: true %>
              </div>
              
              <div class="form-group half">
                <%= form.label :postal_code, "Code postal" %>
                <%= form.text_field :postal_code, placeholder: "Ex: 75019", required: true %>
              </div>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Capacité et tarif</h3>
            
            <div class="form-row">
              <div class="form-group half">
                <%= form.label :capacity, "Capacité (nombre de personnes)" %>
                <%= form.number_field :capacity, min: 1, max: 1000, required: true %>
              </div>
              
              <div class="form-group half">
                <%= form.label :price_per_hour, "Tarif horaire (€)" %>
                <div class="price-input">
                  <%= form.number_field :price_per_hour, min: 1, step: 0.5, required: true %>
                  <span class="price-currency">€/h</span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Photos</h3>
            <p class="section-hint">Des photos de qualité augmentent vos chances de location (minimum 3 recommandé)</p>
            
            <div class="form-group">
              <%= form.label :images, "Ajouter des photos" %>
              <div class="image-upload-container">
                <div class="image-upload-button">
                  <i class="fas fa-cloud-upload-alt"></i>
                  <span>Sélectionner des images</span>
                  <%= form.file_field :images, multiple: true, accept: "image/*", class: "hidden-file-input" %>
                </div>
                <div class="image-upload-hint">
                  <p>Format JPG ou PNG, max 10MB par image</p>
                </div>
              </div>
              <div class="image-previews" id="image-previews">
                <!-- Les aperçus d'images s'afficheront ici via JavaScript -->
              </div>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Disponibilités</h3>
            <p class="section-hint">Définissez les jours et horaires où votre espace est disponible à la location</p>
            
            <div class="availability-container">
              <div class="availability-header">
                <div class="day-header">Jour</div>
                <div class="availability-status-header">Disponible</div>
                <div class="time-header">Horaires</div>
              </div>
              
              <% ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"].each_with_index do |day, index| %>
                <div class="availability-row">
                  <div class="day-name"><%= day %></div>
                  <div class="availability-toggle">
                    <%= check_box_tag "space[availabilities][#{index}][available]", "1", false, class: "availability-checkbox", id: "availability-#{index}" %>
                    <label for="availability-<%= index %>" class="toggle-switch"></label>
                  </div>
                  <div class="time-range">
                    <%= select_tag "space[availabilities][#{index}][start_time]", 
                      options_for_select((8..22).map { |h| ["#{h}:00", "#{h}:00"] }),
                      { include_blank: "Début", disabled: true, class: "time-select start-time" } %>
                    <span class="time-separator">-</span>
                    <%= select_tag "space[availabilities][#{index}][end_time]", 
                      options_for_select((8..22).map { |h| ["#{h}:00", "#{h}:00"] }),
                      { include_blank: "Fin", disabled: true, class: "time-select end-time" } %>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Équipements et services</h3>
            
            <div class="amenities-container">
              <div class="amenity-group">
                <h4>Équipements de base</h4>
                <div class="amenity-checkboxes">
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "wifi", false, id: "amenity-wifi" %>
                    <label for="amenity-wifi">WiFi</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "tables", false, id: "amenity-tables" %>
                    <label for="amenity-tables">Tables et chaises</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "restroom", false, id: "amenity-restroom" %>
                    <label for="amenity-restroom">Toilettes</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "heating", false, id: "amenity-heating" %>
                    <label for="amenity-heating">Chauffage</label>
                  </div>
                </div>
              </div>
              
              <div class="amenity-group">
                <h4>Équipements audio-visuels</h4>
                <div class="amenity-checkboxes">
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "projector", false, id: "amenity-projector" %>
                    <label for="amenity-projector">Vidéoprojecteur</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "screen", false, id: "amenity-screen" %>
                    <label for="amenity-screen">Écran de projection</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "sound_system", false, id: "amenity-sound_system" %>
                    <label for="amenity-sound_system">Système sonore</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "microphone", false, id: "amenity-microphone" %>
                    <label for="amenity-microphone">Microphone</label>
                  </div>
                </div>
              </div>
              
              <div class="amenity-group">
                <h4>Confort et services</h4>
                <div class="amenity-checkboxes">
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "kitchen", false, id: "amenity-kitchen" %>
                    <label for="amenity-kitchen">Cuisine/Coin cuisine</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "coffee", false, id: "amenity-coffee" %>
                    <label for="amenity-coffee">Machine à café</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "refrigerator", false, id: "amenity-refrigerator" %>
                    <label for="amenity-refrigerator">Réfrigérateur</label>
                  </div>
                  <div class="amenity-checkbox">
                    <%= check_box_tag "space[amenities][]", "wheelchair", false, id: "amenity-wheelchair" %>
                    <label for="amenity-wheelchair">Accessible PMR</label>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <div class="form-section">
            <h3>Règles et conditions</h3>
            
            <div class="form-group">
              <%= form.label :rules, "Règles de l'espace" %>
              <%= form.text_area :rules, rows: 3, placeholder: "Ex: Pas de bruit après 22h, pas d'animaux, interdiction de fumer..." %>
            </div>
            
            <div class="form-group">
              <%= form.label :cancellation_policy, "Politique d'annulation" %>
              <%= form.select :cancellation_policy, [
                ["Flexible (annulation gratuite jusqu'à 24h avant)", "flexible"],
                ["Modérée (annulation gratuite jusqu'à 3 jours avant)", "moderate"],
                ["Stricte (annulation gratuite jusqu'à 7 jours avant)", "strict"]
              ], { include_blank: "Sélectionnez une politique d'annulation" }, { required: true } %>
            </div>
          </div>
          
          <div class="terms-agreement">
            <div class="form-checkbox">
              <%= check_box_tag :terms_accepted, "1", false, required: true, id: "terms_accepted" %>
              <label for="terms_accepted">J'accepte les <a href="/terms" target="_blank">conditions générales d'utilisation</a> et je certifie que mon espace respecte les réglementations locales</label>
            </div>
          </div>
          
          <div class="form-actions">
            <%= form.submit "Publier mon annonce", class: "btn-large primary" %>
            <a href="/" class="btn-large secondary">Annuler</a>
          </div>
        <% end %>
      </div>
      
      <div class="host-faq">
        <h2>Questions fréquentes</h2>
        
        <div class="faq-container">
          <div class="faq-item">
            <div class="faq-question">
              <h3>Quels types d'espaces puis-je proposer ?</h3>
              <span class="faq-toggle">+</span>
            </div>
            <div class="faq-answer">
              <p>Vous pouvez proposer tout type d'espace : salle de réunion, atelier, espace de coworking, salle de formation, salle de spectacle, etc. Tant que l'espace respecte nos conditions d'utilisation et les règlements locaux.</p>
            </div>
          </div>
          
          <div class="faq-item">
            <div class="faq-question">
              <h3>Comment sont calculés les frais de service ?</h3>
              <span class="faq-toggle">+</span>
            </div>
            <div class="faq-answer">
              <p>LeLocal prélève une commission de 10% sur chaque réservation. Cette commission permet de financer la plateforme, le service client et l'assurance qui couvre les dommages éventuels.</p>
            </div>
          </div>
          
          <div class="faq-item">
            <div class="faq-question">
              <h3>Comment fonctionne le paiement ?</h3>
              <span class="faq-toggle">+</span>
            </div>
            <div class="faq-answer">
              <p>Les utilisateurs paient en ligne lors de la réservation. Vous recevez le paiement 24h après la fin de la réservation, directement sur votre compte bancaire.</p>
            </div>
          </div>
          
          <div class="faq-item">
            <div class="faq-question">
              <h3>Que se passe-t-il en cas d'annulation ?</h3>
              <span class="faq-toggle">+</span>
            </div>
            <div class="faq-answer">
              <p>Vous pouvez définir vos propres conditions d'annulation (flexibles, modérées ou strictes). En fonction de ces conditions, les utilisateurs peuvent recevoir un remboursement total ou partiel en cas d'annulation.</p>
            </div>
          </div>
          
          <div class="faq-item">
            <div class="faq-question">
              <h3>Dois-je payer des impôts sur mes revenus de location ?</h3>
              <span class="faq-toggle">+</span>
            </div>
            <div class="faq-answer">
              <p>Les revenus générés par la location de votre espace sont imposables. Nous vous recommandons de consulter un conseiller fiscal pour connaître vos obligations spécifiques.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
  
  <% content_for :scripts do %>
  <script>
    document.addEventListener('DOMContentLoaded', function() {
      // Gestion des FAQs
      const faqItems = document.querySelectorAll('.faq-item');
      
      faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        const toggle = item.querySelector('.faq-toggle');
        const answer = item.querySelector('.faq-answer');
        
        question.addEventListener('click', () => {
          // Fermer toutes les autres réponses
          faqItems.forEach(otherItem => {
            if (otherItem !== item) {
              otherItem.classList.remove('active');
              otherItem.querySelector('.faq-answer').style.display = 'none';
              otherItem.querySelector('.faq-toggle').textContent = '+';
            }
          });
          
          // Toggle la réponse actuelle
          item.classList.toggle('active');
          if (item.classList.contains('active')) {
            answer.style.display = 'block';
            toggle.textContent = '−';
          } else {
            answer.style.display = 'none';
            toggle.textContent = '+';
          }
        });
        
        // Cacher toutes les réponses par défaut
        answer.style.display = 'none';
      });
      
      // Gestion des aperçus d'images
      const imageInput = document.querySelector('.hidden-file-input');
      const previewContainer = document.getElementById('image-previews');
      
      if (imageInput) {
        imageInput.addEventListener('change', function() {
          previewContainer.innerHTML = ''; // Vider les aperçus existants
          
          if (this.files) {
            Array.from(this.files).forEach(file => {
              if (!file.type.match('image.*')) {
                return;
              }
              
              const reader = new FileReader();
              
              reader.onload = function(e) {
                const previewDiv = document.createElement('div');
                previewDiv.className = 'image-preview';
                
                const img = document.createElement('img');
                img.src = e.target.result;
                
                const removeBtn = document.createElement('button');
                removeBtn.className = 'remove-image';
                removeBtn.innerHTML = '×';
                removeBtn.addEventListener('click', function(event) {
                  event.preventDefault();
                  previewDiv.remove();
                  // Note: Dans une vraie application, il faudrait aussi gérer la suppression du fichier dans l'input file
                });
                
                previewDiv.appendChild(img);
                previewDiv.appendChild(removeBtn);
                previewContainer.appendChild(previewDiv);
              };
              
              reader.readAsDataURL(file);
            });
          }
        });
      }
      
      // Gestion des disponibilités
      const availabilityCheckboxes = document.querySelectorAll('.availability-checkbox');
      
      availabilityCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
          const row = this.closest('.availability-row');
          const startTimeSelect = row.querySelector('.start-time');
          const endTimeSelect = row.querySelector('.end-time');
          
          if (this.checked) {
            startTimeSelect.disabled = false;
            endTimeSelect.disabled = false;
          } else {
            startTimeSelect.disabled = true;
            endTimeSelect.disabled = true;
          }
        });
      });
    });
  </script>
  <% end %>