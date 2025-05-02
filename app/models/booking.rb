class Booking < ApplicationRecord
    belongs_to :space
    belongs_to :user, optional: true # Optional jusqu'à ce que vous implémentiez Devise
    
    validates :date, :start_time, :end_time, presence: true
    validate :end_time_after_start_time
    
    private
    
    def end_time_after_start_time
      return if end_time.blank? || start_time.blank?
      
      if end_time <= start_time
        errors.add(:end_time, "doit être après l'heure de début")
      end
    end
  end