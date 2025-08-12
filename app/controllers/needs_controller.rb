require "ostruct"

class NeedsController < ApplicationController
  # Rends ces actions publiques (au cas où l'auth soit activée ailleurs)
  skip_before_action :authenticate_user!, only: [:new, :create, :map, :show] rescue nil

  def new
    @need = OpenStruct.new
  end

  def show
    @need = Need.find(params[:id])

    # Fallback de coordonnées si manquantes (centre France)
    @center =
      if @need.latitude.present? && @need.longitude.present?
        [@need.latitude, @need.longitude]
      else
        [46.603354, 1.888334]
      end

    # Petites infos de contact mock si absentes
    @need.contact_email ||= "contact+need#{@need.id}@lelocal.fr"
    @need.contact_phone ||= "+33 6 00 00 #{format('%02d', @need.id % 100)}"
  end

  def create
    raw    = need_params.to_h
    errors = []

    # Champs requis minimaux
    %i[city date_needed contact_email contact_phone].each do |k|
      errors << "Le champ « #{label_for(k)} » est requis." if raw[k].blank?
    end

    # Vérifs de forme
    if raw[:contact_email].present? && (raw[:contact_email] !~ /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
      errors << "Adresse email invalide."
    end
    if raw[:contact_phone].present? && (raw[:contact_phone].gsub(/\D/, '').size < 6)
      errors << "Numéro de téléphone invalide."
    end

    if errors.any?
      @need = OpenStruct.new(raw)
      @need.define_singleton_method(:errors) do
        OpenStruct.new(full_messages: errors, any?: errors.any?, count: errors.size)
      end
      render :new, status: :unprocessable_entity and return
    end

    # Envoi email
    NeedMailer.with(
      need: OpenStruct.new(raw),
      raw_params: raw
    ).notify_admin.deliver_now

    respond_to do |format|
      format.html { redirect_to root_path, notice: "✅ Votre demande a bien été réceptionnée. Merci !" }
      format.json { render json: { ok: true }, status: :ok }
    end
  rescue => e
    Rails.logger.error "[NEEDS_CREATE] #{e.class}: #{e.message}"
    @need = OpenStruct.new(raw || {})
    @need.define_singleton_method(:errors) do
      OpenStruct.new(full_messages: [e.message], any?: true, count: 1)
    end
    render :new, status: :internal_server_error
  end

  def map
    # 1) Récupère les besoins BDD si le modèle existe
    db_needs = defined?(Need) ? Need.limit(100).to_a : []

    # 2) Ajoute quelques besoins simulés (avec user fictif) — sans ID
    sim_needs = build_simulated_needs

    # 3) Normalise tout le monde pour la vue
    @needs = (db_needs + sim_needs).map { |n| normalize_need(n) }

    # 4) Centre de carte
    if params[:city].present? && (c = city_coords(params[:city]))
      @center_coords = c
    elsif @needs.any?
      lat = @needs.map(&:latitude).compact.sum / @needs.size.to_f
      lng = @needs.map(&:longitude).compact.sum / @needs.size.to_f
      @center_coords = [lat, lng]
    else
      @center_coords = [48.8566, 2.3522] # Paris
    end
  end

  private

  # Transforme un Need AR OU un OpenStruct en OpenStruct “safe”
  # Important : on ne conserve une id QUE si le record est réellement persisté et id > 0
  def normalize_need(n)
    id =
      if n.respond_to?(:persisted?) && n.persisted? &&
         n.respond_to?(:id) && n.id.is_a?(Integer) && n.id.positive?
        n.id
      else
        nil
      end

    title = n.respond_to?(:title) && n.title.present? ? n.title : "Besoin d'espace"
    date  = n.respond_to?(:date_needed) && n.date_needed.present? ? n.date_needed : Date.today + 7
    city  = n.respond_to?(:city) && n.city.present? ? n.city : "Paris"

    lat = n.respond_to?(:latitude) ? n.latitude : nil
    lng = n.respond_to?(:longitude) ? n.longitude : nil
    if lat.blank? || lng.blank?
      c = city_coords(city) || [48.8566, 2.3522]
      lat ||= c[0]
      lng ||= c[1]
    end

    display_name =
      if n.respond_to?(:user) && n.user.present? && n.user.respond_to?(:display_name) && n.user.display_name.present?
        n.user.display_name
      elsif n.respond_to?(:contact_email) && n.contact_email.present?
        n.contact_email.split("@").first.capitalize
      else
        "Association"
      end

    OpenStruct.new(
      id: id,  # nil pour les besoins simulés ⇒ pas de /needs/-1 possible
      title: title,
      date_needed: date,
      city: city,
      latitude: lat,
      longitude: lng,
      user: OpenStruct.new(display_name: display_name)
    )
  end

  # Besoins simulés : PAS d'ID ici
  def build_simulated_needs
    [
      OpenStruct.new(
        city: "Nancy", latitude: 48.6937, longitude: 6.1844,
        title: "Atelier créatif – 15/20 pers.", date_needed: Date.today + 10,
        user: OpenStruct.new(display_name: "Collectif Nancy")
      ),
      OpenStruct.new(
        city: "Paris", latitude: 48.8566, longitude: 2.3522,
        title: "Réunion mensuelle", date_needed: Date.today + 5,
        user: OpenStruct.new(display_name: "Association Paris")
      ),
      OpenStruct.new(
        city: "Lyon", latitude: 45.7640, longitude: 4.8357,
        title: "Expo photo", date_needed: Date.today + 20,
        user: OpenStruct.new(display_name: "Club Photo")
      )
    ]
  end

  def city_coords(city)
    lut = {
      "Paris"     => [48.8566, 2.3522],
      "Lyon"      => [45.7640, 4.8357],
      "Nancy"     => [48.6937, 6.1844],
      "Marseille" => [43.2965, 5.3698],
      "Lille"     => [50.6292, 3.0573],
      "Bordeaux"  => [44.8378, -0.5792],
      "Toulouse"  => [43.6047, 1.4442],
    }
    key = city.to_s.strip
    key = key[0].upcase + key[1..] if key.present?
    lut[key]
  end

  def need_params
    params.require(:need).permit(
      :title, :description, :category,
      :address, :city, :postal_code,
      :capacity, :date_needed, :duration, :start_time, :end_time,
      :recurrence, :budget, :surface_min,
      :contact_email, :contact_phone,
      equipment_needs: []
    )
  end

  def label_for(field)
    {
      city: "Ville",
      date_needed: "Date",
      contact_email: "Email",
      contact_phone: "Téléphone"
    }[field] || field.to_s.humanize
  end
end

