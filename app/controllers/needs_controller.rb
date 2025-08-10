require "ostruct"

class NeedsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new, :create] rescue nil

  def new
    @need = OpenStruct.new
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

  private

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
