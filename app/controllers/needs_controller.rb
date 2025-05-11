class NeedsController < ApplicationController
  before_action :set_need, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :map, :new]
  
  # GET /needs
  def index
    @needs = Need.all
   
    # Si le paramètre map est présent, rediriger vers l'action map
    if params[:map] == "true"
      redirect_to map_needs_path
      return
    end
  end
  
  # GET /needs/map
  def map
    @needs = Need.all

    # Préparation des données pour la carte
    if @needs.any? && @needs.first.respond_to?(:latitude) && @needs.first.respond_to?(:longitude)
      @center_coords = [@needs.first.latitude, @needs.first.longitude]
    else
      @center_coords = [46.603354, 1.888334] # Centre de la France par défaut
    end
  end

  # GET /needs/1
  def show
    # Préparer les données pour la carte si besoin
    @marker = {
      lat: @need.latitude,
      lng: @need.longitude,
      info: @need.title,
      id: @need.id
    }
  end

  # GET /needs/new
  def new
    @need = Need.new
  end
  
  # GET /needs/1/edit
  def edit
  end

  # POST /needs
  def create
    @need = Need.new(need_params)
    @need.user = current_user

    if @need.save
      redirect_to @need, notice: 'Votre besoin a été publié avec succès.'
    else
      render :new
    end
  end
  
  # PATCH/PUT /needs/1
  def update
    if @need.update(need_params)
      redirect_to @need, notice: 'Votre besoin a été mis à jour avec succès.'
    else
      render :edit
    end
  end
  
  # DELETE /needs/1
  def destroy
    @need.destroy
    redirect_to needs_path, notice: 'Votre besoin a été supprimé avec succès.'
  end

  private
    # Fonction pour récupérer le besoin à partir de l'ID
    def set_need
      @need = Need.find(params[:id])
    end

    # Paramètres autorisés pour les besoins
    def need_params
      params.require(:need).permit(
        :title, :description, :category, :address, :city, :postal_code, :country,
        :capacity, :date_needed, :start_time, :end_time, :budget, :recurrence,
        :latitude, :longitude, photos: [], equipment_needs: []
      )
    end
end