# frozen_string_literal: true
require "ostruct"

class NeedsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create, :map, :show] rescue nil

  def new
    @need = OpenStruct.new
  end

  def show
    id = params[:id].to_s

    if simulated_id?(id)
      @need = simulated_need_by_id(id)
      return redirect_to(new_need_path, alert: "Ce besoin n'existe pas.") unless @need

      # compléments pour la vue show (évite les NoMethodError sur photos.attached?)
      @need = ensure_show_safe(@need)

    else
      # besoin réel en BDD
      @need = Need.find(id)
    end

    @center =
      if @need.respond_to?(:latitude) && @need.latitude.present? &&
         @need.respond_to?(:longitude) && @need.longitude.present?
        [@need.latitude, @need.longitude]
      else
        [46.603354, 1.888334] # centre France
      end

    # Petites infos de contact par défaut si absentes
    email_fallback = "contact+need#{id}@lelocal.fr"
    phone_fallback = "+33 6 00 00 #{format('%02d', id.to_s.gsub(/\D/, '').to_i % 100)}"

    if @need.respond_to?(:contact_email)
      @need.contact_email ||= email_fallback
    else
      @need = OpenStruct.new(@need.to_h.merge(contact_email: email_fallback))
    end

    if @need.respond_to?(:contact_phone)
      @need.contact_phone ||= phone_fallback
    else
      @need = OpenStruct.new(@need.to_h.merge(contact_phone: phone_fallback))
    end
  end

  def create
    raw    = need_params.to_h
    errors = []

    %i[city date_needed contact_email contact_phone].each do |k|
      errors << "Le champ « #{label_for(k)} » est requis." if raw[k].blank?
    end

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
    db_needs = defined?(Need) ? Need.limit(100).to_a : []
    sim_needs = build_simulated_needs

    # Normalise tout (et force des IDs string)
    @needs = (db_needs + sim_needs).map { |n| normalize_need(n) }

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

  # --- Simulé ? --------------------------------------------------------------

  def simulated_id?(id)
    id.start_with?("simu-")
  end

  def simulated_need_by_id(id)
    build_simulated_needs.find { |n| n.id.to_s == id }
  end

  # --- Normalisation pour la vue map + génération d'ID -----------------------

  def normalize_need(n)
    is_ar = n.respond_to?(:id) && n.class.name == "Need"

    id =
      if is_ar && n.id.present?
        n.id.to_s            # vrai ID BDD
      elsif n.respond_to?(:id) && n.id.to_s.start_with?("simu-")
        n.id.to_s            # déjà au bon format "simu-x"
      else
        "simu-#{SecureRandom.hex(3)}" # fallback
      end

    title = n.respond_to?(:title) && n.title.present? ? n.title : "Besoin d'espace"
    date  = n.respond_to?(:date_needed) && n.date_needed.present? ? n.date_needed : Date.today + 7
    city  = n.respond_to?(:city) && n.city.present? ? n.city : "Paris"

    lat = n.respond_to?(:latitude) ? n.latitude : nil
    lng = n.respond_to?(:longitude) ? n.longitude : nil
    if lat.blank? || lng.blank?
      c = city_coords(city) || [48.8566, 2.3522]
      lat ||= c[0]; lng ||= c[1]
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
      id: id,
      title: title,
      date_needed: date,
      city: city,
      latitude: lat,
      longitude: lng,
      user: OpenStruct.new(display_name: display_name),
      budget: (n.respond_to?(:budget) ? n.budget : nil)
    )
  end

  def build_simulated_needs
    [
      OpenStruct.new(
        id: "simu-1",
        city: "Nancy", latitude: 48.6937, longitude: 6.1844,
        title: "Atelier créatif – 15/20 pers.", date_needed: Date.today + 10,
        budget: 150,
        user: OpenStruct.new(display_name: "Collectif Nancy")
      ),
      OpenStruct.new(
        id: "simu-2",
        city: "Paris", latitude: 48.8566, longitude: 2.3522,
        title: "Réunion mensuelle", date_needed: Date.today + 5,
        budget: nil,
        user: OpenStruct.new(display_name: "Association Paris")
      ),
      OpenStruct.new(
        id: "simu-3",
        city: "Lyon", latitude: 45.7640, longitude: 4.8357,
        title: "Expo photo", date_needed: Date.today + 20,
        budget: 300,
        user: OpenStruct.new(display_name: "Club Photo")
      )
    ]
  end

  # Fournit un objet “photos” inoffensif et de quoi afficher sans casser la vue show
  def ensure_show_safe(obj)
    h = obj.to_h

    photos_stub = Object.new
    photos_stub.define_singleton_method(:attached?) { false }
    photos_stub.define_singleton_method(:first) { nil }

    OpenStruct.new(
      {
        title: "Besoin d'espace",
        description: nil,
        city: nil,
        address: nil,
        date_needed: nil,
        capacity: nil,
        budget: nil,
        contact_email: nil,
        contact_phone: nil,
        latitude: nil,
        longitude: nil,
        photos: photos_stub
      }.merge(h)
    )
  end

  # --- Utilitaires -----------------------------------------------------------

  def city_coords(city)
    lut = {
      "Paris" => [48.8566, 2.3522],
      "Lyon" => [45.7640, 4.8357],
      "Nancy" => [48.6937, 6.1844],
      "Marseille" => [43.2965, 5.3698],
      "Lille" => [50.6292, 3.0573],
      "Bordeaux" => [44.8378, -0.5792],
      "Toulouse" => [43.6047, 1.4442],
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


