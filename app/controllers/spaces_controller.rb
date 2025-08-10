class SpacesController < ApplicationController
  before_action :set_space, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :exception

  # --- LISTE / CARTE ---
  def index
    # 1) Base : vrais espaces en base
    base = Space.all.to_a

    # 2) Ajouter les “simulated_spaces” si la méthode existe, sinon []
    simulated = respond_to?(:simulated_spaces, true) ? Array(simulated_spaces) : []

    # 3) Fusion + tri (tolérant si un objet n’a pas de created_at)
    @spaces = (base + simulated).sort_by do |s|
      (s.respond_to?(:created_at) && s.created_at.present?) ? s.created_at : Time.at(0)
    end.reverse

    # 4) Filtres (appliqués seulement si la méthode correspondante existe)
    @spaces = filter_by_location(@spaces, params[:location]) if params[:location].present? && respond_to?(:filter_by_location, true)
    if params[:date].present? && respond_to?(:filter_by_date_and_time, true)
      @spaces = filter_by_date_and_time(@spaces, params[:date], params[:start_time], params[:end_time])
    end
    @spaces = filter_by_capacity(@spaces, params[:capacity]) if params[:capacity].present? && respond_to?(:filter_by_capacity, true)
    if (params[:min_price].present? || params[:max_price].present?) && respond_to?(:filter_by_price, true)
      @spaces = filter_by_price(@spaces, params[:min_price], params[:max_price])
    end
    @spaces = filter_by_categories(@spaces, params[:categories]) if params[:categories].present? && respond_to?(:filter_by_categories, true)
    @spaces = filter_by_amenities(@spaces, params[:amenities]) if params[:amenities].present? && respond_to?(:filter_by_amenities, true)

    # 5) Vue carte (comportement actuel conservé)
    render :map
  end

  # --- FORM HÔTE ---
  def submit_host
    Rails.logger.info "[SUBMIT_HOST] photos=#{Array(params[:photos]).size}"

    full_address = [params[:address], params[:postal_code], params[:city]]
                    .compact.reject(&:blank?).join(' ')

    @space = Space.new(
      name:           params[:name],
      description:    params[:description],
      category:       params[:category],
      capacity:       params[:capacity].to_i,
      address:        full_address,
      price_per_hour: (params[:price_per_hour].presence || params[:hourly_price]).to_f
    )
    @space.user = current_user if respond_to?(:current_user) && user_signed_in?

    if @space.has_attribute?(:amenities) && params[:equipment].present?
      @space[:amenities] = Array(params[:equipment])
    end

    if @space.save
      Array(params[:photos]).each do |ph|
        Rails.logger.info "[DEBUG_PHOTO] #{ph.inspect} size=#{ph.size if ph.respond_to?(:size)}"
      end

      begin
        HostProposalMailer.with(
          space: @space,
          raw_params: params.to_unsafe_h,
          photos: params[:photos]
        ).notify_admin.deliver_now
      rescue => e
        Rails.logger.error("[MAILER] #{e.class}: #{e.message}")
      end

      render json: { success: true, id: @space.id }
    else
      render json: { success: false, message: @space.errors.full_messages.to_sentence },
             status: :unprocessable_entity
    end
  end

  # --- CRUD ---
  def show
    id = params[:id]
    space_name = params[:space_name]

    unless @space
      if id.to_i < 0
        sim = respond_to?(:get_simulated_space_by_id, true) ? get_simulated_space_by_id(id.to_i) : nil
        @space = sim || (space_name.present? && respond_to?(:get_simulated_space_by_name, true) ? get_simulated_space_by_name(space_name) : nil)
      else
        @space = Space.find_by(id: id)
      end
    end

    unless @space
      flash[:alert] = "L'espace demandé n'a pas été trouvé."
      redirect_to search_spaces_path and return
    end

    @marker = { lat: @space.latitude, lng: @space.longitude, info: @space.name, id: @space.id }
    @reviews = @space.respond_to?(:reviews) ? @space.reviews.includes(:user) : []
    @reservation = Reservation.new if defined?(Reservation)
  end

  def new
    @space = Space.new
  end

  def create
    @space = Space.new(space_params)
    @space.user = current_user if user_signed_in?

    if @space.save
      flash[:notice] = "Votre espace a été créé avec succès et sera vérifié par notre équipe."
      redirect_to @space
    else
      render :new
    end
  end

  def edit; end

  def update
    if @space.update(space_params)
      flash[:notice] = "Les informations de l'espace ont été mises à jour."
      redirect_to @space
    else
      render :edit
    end
  end

  def destroy
    @space.destroy
    flash[:notice] = "L'espace a été supprimé."
    redirect_to spaces_path
  end

  def search
    @location   = params[:location]
    @date       = params[:date]
    @start_time = params[:start_time]
    @end_time   = params[:end_time]
    @capacity   = params[:capacity]
    @category   = params[:category]
    @sort       = params[:sort] || 'rating'

    if @capacity.present?
      if @capacity.include?("-")
        min_capacity, max_capacity = @capacity.split("-").map(&:to_i)
        @capacity_filter = "#{min_capacity}-#{max_capacity} personnes"
      else
        min_capacity = @capacity.to_i
        @capacity_filter = "#{min_capacity}+ personnes"
      end
    end

    # On utilise les simulés si dispo, sinon on retombe sur Space.all
    @spaces = if @location.present?
                if respond_to?(:simulated_spaces_by_city, true)
                  simulated_spaces_by_city(@location)
                else
                  Space.where("address ILIKE :q OR city ILIKE :q", q: "%#{@location}%").to_a rescue Space.all.to_a
                end
              else
                respond_to?(:simulated_spaces, true) ? simulated_spaces : Space.all.to_a
              end

    @center_coords = respond_to?(:city_coordinates, true) ? city_coordinates(@location) : nil

    @spaces = @spaces.select { |s| s.category == @category } if @category.present? && @category != "Toutes les catégories"

    if @capacity.present?
      if @capacity.include?("-")
        min_capacity, max_capacity = @capacity.split("-").map(&:to_i)
        @spaces = @spaces.select { |s| s.capacity >= min_capacity && s.capacity <= max_capacity }
      else
        min_capacity = @capacity.to_i
        @spaces = @spaces.select { |s| s.capacity >= min_capacity }
      end
    end

    case @sort
    when 'price_asc'  then @spaces.sort_by! { |s| s.price_per_hour.to_f }
    when 'price_desc' then @spaces.sort_by! { |s| s.price_per_hour.to_f }.reverse!
    when 'capacity'   then @spaces.sort_by! { |s| s.capacity.to_i }.reverse!
    else                  @spaces.sort_by! { |s| (s.respond_to?(:rating) && s.rating) ? s.rating.to_f : 0.0 }.reverse!
    end
  end

  def new_host
    @space = Space.new
  end

  private

  def set_space
    @space =
      if params[:id].to_i > 0
        Space.find_by(id: params[:id])
      else
        respond_to?(:get_simulated_space_by_id, true) ? get_simulated_space_by_id(params[:id].to_i) : nil
      end
  end

  def space_params
    params.require(:space).permit(:name, :description, :address, :capacity,
                                  :price_per_hour, :category, :rules, :cancellation_policy,
                                  :hourly_price, :country, :minimum_hours,
                                  :latitude, :longitude, photos: [], amenity_ids: [],
                                  amenities: [])
  end
end

