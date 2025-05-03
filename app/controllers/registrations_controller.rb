class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
  
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
      devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    end
  
    # Ajouter cette méthode pour résoudre l'erreur
    def devise_mapping
      @devise_mapping ||= Devise.mappings[:user]
    end
  end