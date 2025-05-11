class RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super
  end

  # POST /resource
  def create
    super
  end

  protected

  # Permettre des paramètres supplémentaires pour l'inscription
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :account_type, 
      :first_name, 
      :last_name, 
      :phone, 
      :association_name, 
      :terms_accepted, 
      :newsletter
    ])
  end

  # Permettre des paramètres supplémentaires pour la mise à jour du compte
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :account_type, 
      :first_name, 
      :last_name, 
      :phone, 
      :association_name, 
      :newsletter
    ])
  end

  # Ajouter cette méthode pour résoudre l'erreur
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end

  
  