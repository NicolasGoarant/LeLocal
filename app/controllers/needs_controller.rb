class NeedsController < ApplicationController
  before_action :set_need, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show, :map]

  # GET /needs
  def index
    @needs = Need.all

    # Redirige vers la carte si ?map=true
    redirect_to map_needs_path if params[:map] == "true"
  end

  # GET /needs/map
  def map
    @needs = Need.all

    # Centrer la carte soit sur le premier besoin géolocalisé, soit sur la France
    first_located = @needs.find { |n| n.latitude.present? && n.longitude.present? }
    @center_coords = if first_located
                       [first_located.latitude, first_located.longitude]
                     else
                       [46.603354, 1.888334] # Centre de la France
                     end
  end

  # GET /needs/:id
  def show
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

  # GET /needs/:id/edit
  def edit; end

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

  # PATCH/PUT /needs/:id
  def update
    if @need.update(need_params)
      redirect_to @need, notice: 'Votre besoin a été mis à jour avec succès.'
    else
      render :edit
    end
  end

  # DELETE /needs/:id
  def destroy
    @need.destroy
    redirect_to needs_path, notice: 'Votre besoin a été supprimé avec succès.'
  end

  private

  def set_need
    @need = Need.find(params[:id])
  end

  def need_params
    params.require(:need).permit(
      :title, :description, :category, :address, :city, :postal_code, :country,
      :capacity, :date_needed, :start_time, :end_time, :budget, :recurrence,
      :latitude, :longitude, photos: [], equipment_needs: []
    )
  end
end
